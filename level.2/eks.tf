resource "aws_kms_key" "eks_key" {
    description             = "EKS KMS Key"
    deletion_window_in_days = 7
    enable_key_rotation     = true

    tags = {
        Environment = var.env_code
        Service     = "EKS"
    }
}

resource "aws_kms_alias" "eks_key_alias" {
    target_key_id = aws_kms_key.eks_key.id
    name          = "alias/eks-kms-key-${var.env_code}"
}

module "eks" {
    source  = "terraform-aws-modules/eks/aws"
    version = "20.11.1"

    cluster_name                    = "eksms"
    cluster_endpoint_public_access  = true
    create_iam_role                 = false
    iam_role_arn                    = aws_iam_role.eks_cluster_role.arn
    vpc_id                          = data.terraform_remote_state.level1.outputs.vpc_id
    subnet_ids                      = data.terraform_remote_state.level1.outputs.private_subnets
    control_plane_subnet_ids        = data.terraform_remote_state.level1.outputs.intra_subnets

    enable_cluster_creator_admin_permissions = true

    cluster_addons = {
        coredns = {
            most_recent = true
        }
        kube-proxy = {
            most_recent = true
        }
        vpc-cni = {
            most_recent = true
        }
    }

    # EKS managed node groups
    eks_managed_node_group_defaults = {
        ami_type        = "AL2_x86_64"
        instance_types  = ["t2.medium"]

        attach_cluster_primary_security_group = true
    }

    eks_managed_node_groups = {
        nginx-cluster-wg = {
            name = "nginx-cluster-wg"

            min_size        = 1
            max_size        = 2
            desired_siez    = 1

            instance_types  = ["t2.small"]
            capacity_type   = "SPOT"

            tags = {
                ExtraTag = "nginx-cluster-wg"
            }
        }
    }
}

resource "kubernetes_namespace" "eksms_ns" {
    metadata {
        name = var.eks_namespace
    }

    depends_on = [module.eks]
}

resource "kubernetes_service_account" "eks_service_account" {
    metadata {
        name        = "eksserviceaccount"
        namespace   = kubernetes_namespace.eksms_ns.metadata.0.name

        labels = {
            "app.kubernetes.io/component" = "controller"
            "app.kubernetes.io/name" = "aws-load-balancer-controller"
        }

        annotations = {
            "eks.amazonaws.com/role-arn" = aws_iam_role.AWSLoadBalancerControllerIAM_role.arn
        }
    }

    depends_on = [module.eks]
}

resource "kubernetes_deployment" "deployment" {
  metadata {
    name      = "deployment-nginx"
    namespace = kubernetes_namespace.eksms_ns.metadata.0.name

    labels = {
      tier = "frontend"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app.kubernetes.io/name = "app-eksms"
      }
    }

    template {
      metadata {
        labels = {
          app.kubernetes.io/name = "app-eksms"
        }
      }

      spec {
        container {
          image = "nginx:latest"
          name  = "app-eksms"
          
          port {
            container_port = 8080
          }

          resources {
            limits = {
              cpu    = "1"
              memory = "256Mi"
            }
            requests = {
              cpu    = "500m"
              memory = "30Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 8080

              http_header {
                name  = "X-Custom-Header"
                value = "SSREKS"
              }
            }

            initial_delay_seconds = 2
            period_seconds        = 2
          }
        }
      }
    }
  }
}
