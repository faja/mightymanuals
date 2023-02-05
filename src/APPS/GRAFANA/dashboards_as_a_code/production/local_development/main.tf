terraform {
  required_version = "~> 1.3.0"
  required_providers {
    grafana = {
      source = "grafana/grafana"
      version = "= 1.29.0"
    }
  }
}

provider "grafana" {
  url = "http://grafana:3000"
  auth = "admin:admin"
}

##
# for development time please select/uncomment only one dashboard,
# the one, you are working on, this will speed up terraform apply process
locals {
  dashboards = {
      System = [
         "Prometheus"
      ]
  }
}

module "grafana_dashboards" {
  source = "./modules/grafana_dashboards"

  for_each = local.dashboards

  folder     = each.key
  path       = "../src/dashboards_json"
  dashboards = each.value
}

resource "grafana_data_source" "prometheus" {
  type       = "prometheus"
  name       = "prometheus"
  url        = "http://172.17.0.1:9090"
  is_default = true
}
