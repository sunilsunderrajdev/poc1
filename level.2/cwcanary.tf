data "archive_file" "userstatuscanary_archive_file" {
    source_path  = "../lambda/userstatuscanary"
    output_path = "../lambda/userstatuscanary.zip"
    type        = "zip"
}

resource "aws_synthetics_canary" "userstatus_canary" {
  name                  = "userstatus_canary"
  artifact_s3_location  = "s3://${var.account}_userstatus_canary_s3/"
  execution_role_arn    = aws_iam_role.userstatus_canary_role.arn
  handler               = "userstatuscanary.handler"
  zip_file              = data.archive_file.userstatuscanary_archive_file.output_path
  runtime_version       = "syn-python-selenium-1.1"
  delete_lambda         = true

  schedule {
    expression = "rate(0 minute)"
  }
}
