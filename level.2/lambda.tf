data "archive_file" "archive_file" {
    source_dir  = "../lambda/"
    output_path = "../lambda/userstatus.zip"
    type        = "zip"
}

resource "aws_lambda_function" "userstatus_lambda" {
    function_name   = "userstatus"
    handler         = "handler.lamdba_handler"
    role            = aws_iam_role.lambda_exec_role.arn
    runtime         = "python3.7"

    filename            = data.archive_file.archive_file.output_path
    source_code_hash    = data.archive_file.archive_file.output_base64sha256

    timeout     = 30
    memory_size = 128

    depends_on = [
        aws_iam_role_policy_attachment.lambda_role_policy
    ]
}

resource "aws_lambda_permission" "allows_sqs_to_trigger_lambda" {
    statement_id    = "AllowExecutionFromSQS"
    action          = "lambda:InvokeFunction"
    function_name   = aws_lambda_function.userstatus_lambda.function_name
    principle       = "sqs.amazonaws.com"
    source_arn      = aws_sqs_queue.userstatus_sqs.arn
}
