# Data file for observability permissions to all resources
data "template_file" "observability_policy_file" {
    template = file("../policies/observability_permission.json")
}

# Policy for Observability permissions to all resources
resource "aws_iam_policy" "observability_policy" {
    name = "observability_policy"

    policy = data.template_file.observability_policy_file.rendered
}

# API Gateway permissions
resource "aws_iam_role" "apigtw_role" {
    name = "apigtw_role"

    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "apigateway.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

# Data file for API Gateway permissions to SQS and CloudWatch
data "template_file" "apigtw_policy_file" {
    template = file("../policies/apigtw_permission.json")

    vars = {
        sqs_arn   = aws_sqs_queue.userstatus_sqs.arn
    }
}

# Policy for API Gateway permissions to SQS and CloudWatch
resource "aws_iam_policy" "apigtw_policy" {
    name = "apigtw_policy"

    policy = data.template_file.apigtw_policy_file.rendered
}

# Attach the API Gateway policy to it's role
resource "aws_iam_role_policy_attachment" "apigtw_role_policy" {
    role       =  aws_iam_role.apigtw_role.name

    policy_arn =  aws_iam_policy.apigtw_policy.arn
}

# Lambda Role
resource "aws_iam_role" "userstatusupdatedb_lambda_role" {
  name               = "userstatusupdatedb_lambda_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Data file for Lamdba access to SQS and CloudWatch
data "template_file" "userstatusupdatedb_lambda_policy_file" {
  template = file("../policies/lambda_permission.json")

  vars = {
    sqs_arn   = aws_sqs_queue.userstatus_sqs.arn
  }
}

# Policy for Lamdba access to SQS and CloudWatch
resource "aws_iam_policy" "userstatusupdatedb_lambda_policy" {
  name          = "userstatusupdatedb_lambda_policy"
  description   = "IAM policy for lambda Being invoked by SQS"
  policy        = data.template_file.userstatusupdatedb_lambda_policy_file.rendered
}

resource "aws_iam_role_policy_attachment" "userstatusupdatedb_lambda_role_policy" {
  role       = aws_iam_role.userstatusupdatedb_lambda_role.name
  policy_arn = aws_iam_policy.userstatusupdatedb_lambda_policy.arn
}

# Canary permissions
resource "aws_iam_role" "userstatus_canary_role" {
    name = "userstatus_canary_role"

    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

data "template_file" "userstatus_canary_policy_file" {
  template = file("../policies/userstatuscanary_permission.json")

  vars = {
    accountId = var.account
    region    = var.region
  }
}

resource "aws_iam_policy" "userstatus_canary_policy" {
  name          = "userstatus_canary_policy"
  description   = "IAM policy for userstatus canary"
  policy        = data.template_file.userstatus_canary_policy_file.rendered
}

resource "aws_iam_role_policy_attachment" "userstatus_canary_role_policy" {
  role       = aws_iam_role.userstatus_canary_role.name
  policy_arn = aws_iam_policy.userstatus_canary_policy.arn
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
resource "aws_iam_role_policy_attachment" "apigtw_role_observability_policy" {
    role       =  aws_iam_role.apigtw_role.name
    policy_arn =  aws_iam_policy.observability_policy.arn
}

resource "aws_iam_role_policy_attachment" "userstatus_canary_role_observability_policy" {
  role       = aws_iam_role.userstatus_canary_role.name
  policy_arn = aws_iam_policy.observability_policy.arn
}

resource "aws_iam_role_policy_attachment" "userstatusupdatedb_lambda_role_observability_policy" {
  role       = aws_iam_role.userstatusupdatedb_lambda_role.name
  policy_arn = aws_iam_policy.observability_policy.arn
}
