resource "aws_sqs_queue" "userstatus_sqs" {
    name                        = "userstatus-sqs"
    delay_seconds               = 0
    visibility_timeout_seconds  = 10
    max_message_size            = 2048
    message_retention_seconds   = 86400
    receive_wait_time_seconds   = 10
    sqs_managed_sse_enabled     = true
}
