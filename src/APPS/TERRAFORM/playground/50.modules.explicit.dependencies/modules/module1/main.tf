variable "role_name" {
  type = string
}

data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "default" {
  name = var.role_name
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
}

output "role_name" {
  value = aws_iam_role.default.name
}
