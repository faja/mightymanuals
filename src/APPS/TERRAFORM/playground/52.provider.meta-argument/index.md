[official docs](https://developer.hashicorp.com/terraform/language/meta-arguments/resource-provider)

```
// to select a provider which should be use to create a resource
// use `provider` meta-argument
// it expects <PROVIDER>.<ALIAS> reference

provider "aws" {
  ...
  alias = "eu-central-1"
}

resource "..." "..." {
  ...
  provider = aws.eu-central-1
}
```
