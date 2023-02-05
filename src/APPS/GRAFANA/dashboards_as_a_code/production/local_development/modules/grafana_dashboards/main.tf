terraform {
  required_version = "~> 1.3.0"
  required_providers {
    grafana = {
      source = "grafana/grafana"
      version = "~> 1.29.0"
    }
  }
}

variable "folder" {
  type = string
}

variable "dashboards" {
  type = list(string)
}

variable "path" {
  type = string
}

resource "grafana_folder" "main" {
  title = var.folder
}

resource "grafana_dashboard" "main" {
  for_each = {
    for dashboard in var.dashboards : dashboard => true
  }

  folder      = grafana_folder.main.id
  config_json = file("${path.root}/${var.path}/${var.folder}/${each.key}.json")
}
