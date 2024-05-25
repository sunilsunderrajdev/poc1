module "eks" {
    source  = "terraform-aws-modules/eks/aws"
    version = "20.11.1"

    cluster_name                    = "promexporter"
    cluster_endpoint_public_access  = true

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

    vpc_id                      = data.terraform_remote_state.level1.outputs.vpc_id
    subnet_ids                  = data.terraform_remote_state.level1.outputs.private_subnets
    control_plane_subnet_ids    = data.terraform_remote_state.level1.outputs.intra_subnets

    # EKS managed node groups
    eks_managed_node_group_defaults = {
        ami_type        = "AL2_x86_64"
        instance_types  = ["t2.medium"]

        attach_cluster_primary_security_group = true
    }

    eks_managed_node_groups = {
        amc-cluster-wg = {
            min_size        = 1
            max_size        = 2
            desired_siez    = 1

            instance_types  = ["t2.medium"]
            capacity_type   = "SPOT"

            tags = {
                ExtraTag = "promcwexporter"
            }

        }
    }
}
