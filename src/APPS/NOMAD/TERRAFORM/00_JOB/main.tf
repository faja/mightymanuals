terraform {
  required_version = "= 1.2.8"

  required_providers {
    nomad = {
      source = "hashicorp/nomad"
      version = "1.4.18"
    }
  }
}

provider "nomad" {
  # if this is empty, all the configs are taken from ENV VARIABLES
  # NOMAD_ADDR
  # NOMAD_REGION
  address = "http://127.0.0.1:4646"
}

locals {
  jobspec_vars = {
    job_name = "my_first_job"
  }
}

resource "nomad_job" "job" {
  jobspec = templatefile(
    "jobspec.tftpl",
    local.jobspec_vars,
  )
  purge_on_destroy = true # default is false
  detach  = false         # default is true
}
