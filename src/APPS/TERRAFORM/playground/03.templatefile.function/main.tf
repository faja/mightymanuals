terraform {}

variable "filespec_vars" {
  type    = any
  default = {
    simple_string = "this is just a simple string"
    simple_array = ["value1", "value2", "value3"]
    simple_map = {
      key1 = "val1\nnewline\nelo"
      key2 = "val2"
    }
  }
}

locals {
  filespec = templatefile(
    "${path.module}/filespec.tftpl",
    var.filespec_vars,
  )
}

resource "local_file" "main" {
  filename = "./file.rendered"
  content  = local.filespec
}

output "filespec" {
  value = local.filespec
}
