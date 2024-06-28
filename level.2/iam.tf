locals {
    cluster_oidc            = replace("${module.eks.cluster_oidc_issuer_url}", "https://", "")
    cluster_service_account = format("%s:%s",kubernetes_namespace.eksms_ns.metadata.0.name,kubernetes_service_account.eks_service_account.metadata.0.name)
}

# Data file for observability permissions to all resources
data "template_file" "observability_policy_file" {
    template = file("../policies/observability_policy.json")
}

# Policy for Observability permissions to all resources
resource "aws_iam_policy" "observability_policy" {
    name = "observability_policy"

    policy = data.template_file.observability_policy_file.rendered
}

# EKS cluster permissions
resource "aws_iam_role" "eks_cluster_role" {
    name = "eks_cluster_role"

    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "eks.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_role.name
}

# EKS node group permissions
resource "aws_iam_role" "eks_node_group_role" {
    name = "eks_node_group_role"

    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "eks-node-group-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks-node-group-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks-node-group-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group_role.name
}

# Attach observability policy to all roles
resource "aws_iam_role_policy_attachment" "node_group_role_observability_policy" {
    role       =  aws_iam_role.eks_node_group_role.name
    policy_arn =  aws_iam_policy.observability_policy.arn
}

resource "aws_iam_role_policy_attachment" "eks_cluster_role_observability_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = aws_iam_policy.observability_policy.arn
}

resource "aws_iam_role_policy_attachment" "AWSLoadBalancerControllerIAM_role_observability_policy" {
  role       = aws_iam_role.AWSLoadBalancerControllerIAM_role.name
  policy_arn = aws_iam_policy.observability_policy.arn
}

# AWS Load Balancer Controller permissions
resource "aws_iam_role" "AWSLoadBalancerControllerIAM_role" {
    name = "AWSLoadBalancerControllerIAM_role"

    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::${var.account}:oidc-provider/${local.cluster_oidc}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "${local.cluster_oidc}:aud": "sts.amazonaws.com",
                    "${local.cluster_oidc}:sub": "system:serviceaccount:${local.cluster_service_account}"
                }
            }
        }
    ]
}
EOF
}

# Data file for AWS Load Balancer Controller permissions to resources
data "template_file" "AwsLoadBalancerController_policy_file" {
    template = file("../policies/AWSLoadBalancerControllerIAM_policy.json")
}

# Policy for AWS Load Balancer Controller permissions to all resources
resource "aws_iam_policy" "AWSLoadBalancerControllerIAM_policy" {
    name = "AWSLoadBalancerControllerIAM_policy"

    policy = data.template_file.AwsLoadBalancerController_policy_file.rendered
}

resource "aws_iam_role_policy_attachment" "AWSLoadBalancerControllerIAM_policy_attachment" {
  role       = aws_iam_role.AWSLoadBalancerControllerIAM_role.name
  policy_arn = aws_iam_policy.AWSLoadBalancerControllerIAM_policy.arn
}
