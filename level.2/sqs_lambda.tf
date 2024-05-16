resource "aws_lambda_permission" "allows_sqs_to_trigger_lambda" {
    statement_id    = "AllowExecutionFromSQS"
    action          = "lambda:InvokeFunction"
    function_name   = aws_lambda_function.userstatus_lambda.function_name
    principal       = "sqs.amazonaws.com"
    source_arn      = aws_sqs_queue.userstatus_sqs.arn
}

# Trigger lambda on message to SQS
resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  batch_size       = 1
  event_source_arn = aws_sqs_queue.userstatus_sqs.arn
  enabled          = true
  function_name    = aws_lambda_function.userstatus_lambda.arn
}
