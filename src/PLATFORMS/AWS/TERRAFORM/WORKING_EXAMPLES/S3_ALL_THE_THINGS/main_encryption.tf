// https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration
// https://docs.aws.amazon.com/AmazonS3/latest/userguide/serv-side-encryption.html

// encrypt with SSE-S3
server_side_encryption_configuration {
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

// encrypt with KMS aws/s3 key
server_side_encryption_configuration {
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = "aws/s3"
    }
  }
}

// encrypt with own KMS key
server_side_encryption_configuration {
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = key_id
    }
  }
}
