#

- terraform
```
// https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

locals {
  xxx = {
    owner = "myOrg"
    repo  = "myRepo"
  }
}

// https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "xxx_gh_actions_assume_policy" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${local.xxx.owner}/${local.xxx.repo}:*"]
    }
  }
}

// https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "xxx" {
  name               = "${replace(title(local.account_name), "-", "")}GitHubActionsTokenizer"
  assume_role_policy = data.aws_iam_policy_document.xxx_gh_actions_assume_policy.json

  tags = {
    "managed-by"          = "terraform",
    "terraform:repo-path" = "${local.repo_path}/iam-oidc-github-actions"
  }
}

// https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "xxx_gh_actions_role_policy" {
  statement {
    effect    = "Allow"
    actions   = ["ec2:DescribeInstanceStatus"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:StartInstances",
      "ec2:StopInstances",
    ]
    #resources = ["arn:aws:ec2:*:*:instance/${local.xxx_instance_id}"]
    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Environment"
      values   = ["dev"]
    }
  }
}

// https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy
resource "aws_iam_role_policy" "xxx" {
  name   = "xxx"
  role   = aws_iam_role.xxx.id
  policy = data.aws_iam_policy_dcument.xxx_gh_actions_role_policy.json
}
```

- action
```
---
name: aws - DEV

on:
  workflow_dispatch: # manual trigger

permissions:
  id-token: write
  contents: read

env:
  AWS_ROLE: arn:aws:iam::0123456789:role/RoleName
  AWS_REGION: eu-west-1
  AWS_INSTANCE_ID: i-abc0123456789

jobs:
  stop-dev-ec2:
    name: stop dev ec2
    runs-on: ubuntu-latest
    timeout-minutes: 4

    steps:
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ AWS_ROLE }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Stop EC2 instance
        run: |
          STATUS=$(aws ec2 describe-instance-status --instance-ids ${{ env.INSTANCE_ID }} --query 'InstanceStatuses[0].InstanceState.Name' --output text)

          if test ${STATUS} == "stopped"; then
            echo Instance already stopped
            exit 0
          fi

          if test ${STATUS} != "running"; then
            echo "Instance not in running state (current state: ${STATUS})"
            exit 1
          fi

          echo aws ec2 stop-instances --instance-ids ${{ env.INSTANCE_ID }}
```
