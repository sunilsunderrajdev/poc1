data "archive_file" "lambda_archive_file" {
    source_dir  = "../lambda/"
    output_path = "../lambda/userstatus.zip"
    type        = "zip"
}

resource "aws_lambda_function" "userstatus_lambda" {
    function_name   = "userstatus"
    handler         = "handler.lamdba_handler"
    role            = aws_iam_role.userstatus_lambda_role.arn
    runtime         = "python3.12"

    filename            = data.archive_file.lambda_archive_file.output_path
    source_code_hash    = data.archive_file.lambda_archive_file.output_base64sha256

    timeout     = 30
    memory_size = 128

    depends_on = [
        aws_iam_role_policy_attachment.userstatus_lambda_role_policy
    ]
}
