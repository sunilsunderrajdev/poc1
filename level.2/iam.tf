# Data file for observability permissions to all resources
data "template_file" "observability_policy_file" {
    template = file("../policies/observability_permission.json")
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
