data "archive_file" "lambda_archive_file" {
    source_file  = "../lambdas/userstatusupdatedb.py"
    output_path = "../lambdas/userstatusupdatedb.zip"
    type        = "zip"
}

resource "aws_lambda_function" "userstatusupdatedb_lambda" {
    function_name   = "userstatusupdatedb"
    handler         = "userstatusupdatedb.lambda_handler"
    role            = aws_iam_role.userstatusupdatedb_lambda_role.arn
    runtime         = "python3.12"

    filename            = data.archive_file.lambda_archive_file.output_path
    source_code_hash    = data.archive_file.lambda_archive_file.output_base64sha256

    timeout     = 30
    memory_size = 128

    depends_on = [
        aws_iam_role_policy_attachment.userstatusupdatedb_lambda_role_policy
    ]
}
