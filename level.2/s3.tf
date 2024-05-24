resource "aws_s3_bucket" "userstatus_canary_s3" {
  bucket  = "${var.account}-userstatus-canary-s3"
  tags    = {
	Name          = "userstatus_canary_s3"
	Environment    = "Development"
  }
}
