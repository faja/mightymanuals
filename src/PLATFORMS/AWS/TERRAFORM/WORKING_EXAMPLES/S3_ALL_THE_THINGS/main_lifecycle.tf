/*
 *
 * TODO add more sutff here
 *
 */

resource "aws_s3_bucket_lifecycle_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  // {{{ retention per path
  rule {
    id     = "DeleteAfter14Days"
    status = "Enabled"

    filter {
      prefix = "somepath/"
    }

    expiration {
      days = 14
    }
  }
  // }}}
}
