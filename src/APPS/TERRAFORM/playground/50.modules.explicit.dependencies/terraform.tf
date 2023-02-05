terraform {
  required_version = "= 1.3.2"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.34.0"
    }
  }
}

provider "aws" {
  profile = "xxx"
  region  = "eu-west-1"
}

locals {
  state_envs = ["DeleteMeTest02"]
}

module "module1" {
  source    = "./modules/module1"

  for_each  = toset(local.state_envs)
  role_name = each.key
}

module "module2" {
  source    = "./modules/module2"
  depends_on = [module.module1]

  for_each  = toset(local.state_envs)
  role_name = module.module1[each.key].role_name
}
