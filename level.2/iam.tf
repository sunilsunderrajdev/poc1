resource "aws_iam_role" "userstatus_sqs_role" {
    name = "userstatus-sqs-role"

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

data "template_file" "apigtw_policy_file" {
    template = file("../policies/apigtw_permission.json")

    vars = {
        sqs_arn   = aws_sqs_queue.userstatus_sqs.arn
    }
}

resource "aws_iam_policy" "apigtw_policy" {
    name = "apigtw-sqs-cloudwatch-policy"

    policy = data.template_file.apigtw_policy_file.rendered
}


resource "aws_iam_role_policy_attachment" "apigtw_exec_role" {
    role       =  aws_iam_role.userstatus_sqs_role.name

    policy_arn =  aws_iam_policy.apigtw_policy.arn
}

# Add a Lambda permission that allows the specific SQS to invoke it

data "template_file" "lambda_policy" {
  template = file("../policies/lambda_permission.json")

  vars = {
    sqs_arn   = aws_sqs_queue.userstatus_sqs.arn
  }
}

resource "aws_iam_policy" "lambda_sqs_policy" {
  name          = "lambda_policy_db"
  description   = "IAM policy for lambda Being invoked by SQS"
  policy        = data.template_file.lambda_policy.rendered
}

resource "aws_iam_role" "lambda_exec_role" {
  name               = "userstatus-lambda-db"
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

resource "aws_iam_role_policy_attachment" "lambda_role_policy" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_sqs_policy.arn
}
