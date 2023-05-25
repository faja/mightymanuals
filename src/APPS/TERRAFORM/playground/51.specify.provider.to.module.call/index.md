[official docs](https://developer.hashicorp.com/terraform/language/modules/develop/providers#passing-providers-explicitly)

```hcl
// lets say we have two providers defined, for two different regions
provider "aws" {
  region  = "eu-west-1"
  profile = "xyzzy"
}

provider "aws" {
  alias   = "us-east-1"
  region  = "us-east-1"
  profile = "xyzzy"
}

// to pas a specific provider to a module we
module "..." {
  ...

  providers = {
    aws = aws.us-east-1
  }
}
```
