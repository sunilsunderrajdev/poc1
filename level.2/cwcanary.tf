data "archive_file" "userstatuscanary_archive_file" {
    source_dir  = "../lambda/userstatuscanary"
    output_path = "../lambda/userstatuscanary.zip"
    type        = "zip"
}

resource "aws_synthetics_canary" "userstatus_canary" {
  name                  = "userstatus_canary"
  artifact_s3_location  = "s3://${aws_s3_bucket.userstatus_canary_s3.id}"
  execution_role_arn    = aws_iam_role.userstatus_canary_role.arn
  handler               = "userstatuscanary.handler"
  zip_file              = data.archive_file.userstatuscanary_archive_file.output_path
  runtime_version       = "${var.synthetics_selenium_python}"
  delete_lambda         = true
  start_canary          = true

  schedule {
    expression = "rate(1 minute)"
  }
}
