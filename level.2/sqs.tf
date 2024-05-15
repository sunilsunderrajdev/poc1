resource "aws_sqs_queue" "userstatus_sqs" {
    name                        = "userstatus-sqs"
    delay_seconds               = 0
    visibility_timeout_seconds  = 10
    max_message_size            = 2048
    message_retention_seconds   = 86400
    receive_wait_time_seconds   = 10
    sqs_managed_sse_enabled     = true
}

data "aws_iam_policy_document" "userstatus_sqs_policy" {
    statement {
        sid     = "userstatussqsstatement"
        effect  = "Allow"

        principals {
            type        = "AWS"
            identifiers = ["*"]
        }

        actions = [
            "sqs:ListQueues",
            "sqs:SendMessage",
            "sqs:ReceiveMessage"
        ]

        resources = [
            aws_sqs_queue.userstatus_sqs.arn
        ]
    }
}

resource "aws_sqs_queue_policy" "userstatus_sqs_policy" {
    queue_url   = aws_sqs_queue.userstatus_sqs.id
    policy      = data.aws_iam_policy_document.userstatus_sqs_policy.json
}
