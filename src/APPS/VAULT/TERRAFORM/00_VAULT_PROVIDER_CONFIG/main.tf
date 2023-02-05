terraform {
  required_version = "1.3.7"

  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "3.12.0"
    }
  }
}

##
# empty provider takes all the "connection" and "authentication"
# details from env variables
provider vault {}

##
# IMPORTANT!!!
# to be able to use vault provider, you need `update` capability on
# `auth/token/create` path
#
# the reason behind it is vault creates temporary, short lived child token
# and uses it further instead of provided/original one

// path "auth/token/create" {
//   capabilities = ["update"]
// }
