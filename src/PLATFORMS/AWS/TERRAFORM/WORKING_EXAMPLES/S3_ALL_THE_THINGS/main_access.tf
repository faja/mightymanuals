/*
 * Generally, here is the list of actions
 *
 * RO:
 *   "s3:GetObject",
 *   "s3:ListBucket",
 * WO:
 *   "s3:PutObject"
 * RW:
 *   "s3:GetObject",
 *   "s3:ListBucket",
 *   "s3:PutObject"
 */

data "aws_iam_policy_document" "main" {
  // {{{ write only to a specific path
  statement {
    sid     = "WriteOnlyToSomePath"
    effect  = "Allow"
    actions = ["s3:PutObject"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:user/${local.user_name}"]
    }
    resources = ["arn:aws:s3:::${local.bucket_name}/xyzzy/*"]
  }
  // }}}
  // {{{ read only from a specific path
  statement {
    sid     = "ListObjectInSpecificPath"
    effect  = "Allow"
    actions = ["s3:ListBucket"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:user/${local.user_name}"]
    }
    resources = ["arn:aws:s3:::${local.bucket_name}"]
    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["xyzzy/*"]
    }
  }
  statement {
    sid     = "GetObjectInSpecificPath"
    effect  = "Allow"
    actions = ["s3:GetObject"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:user/${local.user_name}"]
    }
    resources = ["arn:aws:s3:::${local.bucket_name}/xyzzy/*"]
  }
  // }}}
}

resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.main.json
}
