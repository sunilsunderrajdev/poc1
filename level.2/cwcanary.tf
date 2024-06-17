locals {
  statusupdatecanary_source_code      = "../lambdas/statusupdatecanary/python/statusupdatecanary.py"
  statusupdatecanary_source_code_hash = sha256(file(local.statusupdatecanary_source_code))

  statuscheckcanary_source_code      = "../lambdas/statuscheckcanary/python/statuscheckcanary.py"
  statuscheckcanary_source_code_hash = sha256(file(local.statuscheckcanary_source_code))
}

data "archive_file" "statusupdatecanary_archive_file" {
    source_dir  = "../lambdas/statusupdatecanary"
    output_path = "../lambdas/statusupdatecanary_${local.statusupdatecanary_source_code_hash}.zip"
    type        = "zip"
}

resource "aws_synthetics_canary" "statusupdate_canary" {
  name                  = "statusupdate_canary"
  artifact_s3_location  = "s3://${aws_s3_bucket.userstatus_canary_s3.id}"
  execution_role_arn    = aws_iam_role.userstatus_canary_role.arn
  handler               = "statusupdatecanary.handler"
  zip_file              = data.archive_file.statusupdatecanary_archive_file.output_path
  runtime_version       = "${var.synthetics_selenium_python}"
  delete_lambda         = true
  start_canary          = true

  schedule {
    expression = "rate(1 minute)"
  }
}

data "archive_file" "statuscheckcanary_archive_file" {
    source_dir  = "../lambdas/statuscheckcanary"
    output_path = "../lambdas/statuscheckcanary_${local.statuscheckcanary_source_code_hash}.zip"
    type        = "zip"
}

resource "aws_synthetics_canary" "statuscheck_canary" {
  name                  = "statuscheck_canary"
  artifact_s3_location  = "s3://${aws_s3_bucket.userstatus_canary_s3.id}"
  execution_role_arn    = aws_iam_role.userstatus_canary_role.arn
  handler               = "statuscheckcanary.handler"
  zip_file              = data.archive_file.statuscheckcanary_archive_file.output_path
  runtime_version       = "${var.synthetics_selenium_python}"
  delete_lambda         = true
  start_canary          = true

  schedule {
    expression = "rate(10 minutes)"
  }
}
