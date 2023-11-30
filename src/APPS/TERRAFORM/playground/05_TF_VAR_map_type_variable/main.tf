terraform {}

variable "some_map" {
  type = map(any)
  default = {
    key1 = "value1"
    key2 = "value2"
  }
}

output "some_map" {
  value = var.some_map
}

//
// terraform apply
// TF_VAR_some_map='{"key3":"value3"}' terraform apply
//
