variable "vault_path" {
  type    = string
  default = "secret/xxx"
}

variable "some_secret_value" {
  type      = string
  sensitive = true
}

resource "vault_generic_secret" "xxx" {
  path      = var.vault_path
  data_json = jsonencoded({
    XXX_TOKEN = var.some_secret_value
  })
}
