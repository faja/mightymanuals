/*
 * there is not much these days to set in `aws_s3_bucket` resource itself
 * most configuration has been split into dedicated resources `aws_s3_*`
 *
 */

locals {
  bucket_name = "xyzzy"
}

// https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "main" {
  bucket = local.bucket_name

  tags = {
    "Name"      = local.bucket_name
    "managedBy" = "terraform"
  }
}

// https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

// https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl
resource "aws_s3_bucket_acl" "main" {
  bucket = aws_s3_bucket.main.id

  acl = "private"
}

// https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = "Disabled" // available: "Enabled", "Suspended", "Disabled"
    //mfa_delete = "Disabled" // available: "Enabled", "Disabled", can't be specified if versioning is "Disabled"
  }
}
