data "aws_iam_policy_document" "ssr_test_oidc_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:default:aws-test"]
    }

    principals {
      identifiers = [module.eks.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "ssr_test_oidc" {
  assume_role_policy = data.aws_iam_policy_document.ssr_test_oidc_assume_role_policy.json
  name               = "ssr_test-oidc"
}

resource "aws_iam_policy" "ssr_test-policy" {
  name = "ssr_test-policy"

  policy = jsonencode({
    Statement = [{
      Action = [
        "s3:ListAllMyBuckets",
        "s3:GetBucketLocation"
      ]
      Effect   = "Allow"
      Resource = "arn:aws:s3:::*"
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "ssr_test_attach" {
  role       = aws_iam_role.ssr_test_oidc.name
  policy_arn = aws_iam_policy.ssr_test-policy.arn
}

output "ssr_test_policy_arn" {
  value = aws_iam_role.ssr_test_oidc.arn
}
