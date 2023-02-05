variable "role_name" {
  type = string
}

data "aws_iam_role" "default" {
  name = var.role_name
}
