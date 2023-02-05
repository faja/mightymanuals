terraform {
  required_version = "= 1.3.3"

  required_providers {
    merge = {
      source = "LukeCarrier/merge"
      version = "0.1.1"
    }
  }
}

// provider "merge" {} 


/**
 *
 * saves `./jobspec.nomad` file with rendered job spec to a local filesystem
 *
 */
variable "save_spec_file" {
  type    = bool
  default = true
}

/**
 * first of all we do have default `values.yaml`
 * the file that contain all default values
 * it comes with the spec module(chart)
 *
 * this is strongly inspired by helm
 */
locals {
  values = yamldecode(file("${path.module}/values.yaml"))
}

/**
 * we do accept list of value object
 * to override the defaults
 *
 */
variable "values" {
  type    = any
  default = []
}

/**
 *
 * the merging happens here
 *
 */
data "merge_merge" "values" {
  // default values.yaml
  input {
    format = "yaml"
    data = yamlencode(local.values)
  }

  // values from variable
  dynamic "input" {
    for_each = var.values
    content {
      format = "yaml"
      data   = yamlencode(input.value)
    }
  }

  output_format = "yaml"
}

// merged output
output "merge_merged_values" {
  value = data.merge_merge.values.output
}

// lets render the spec
locals {
  jobspec = templatefile(
    "${path.module}/jobspec.nomadtpl",
    yamldecode(data.merge_merge.values.output)
  )
}

output "jobspec" {
  value = local.jobspec
}

resource "local_file" "job" {
  count = var.save_spec_file ? 1 : 0

  filename        = "./jobspec.nomad"
  content         = local.jobspec
  file_permission = "0644"
}
