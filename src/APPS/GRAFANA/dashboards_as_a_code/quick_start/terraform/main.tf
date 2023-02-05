terraform {
  required_providers {
    grafana = {
      source = "grafana/grafana"
      version = "1.28.1"
    }
  }
}

provider "grafana" {
  url = "http://127.0.0.1:3000"
  auth = "admin:admin"
}

resource "grafana_folder" "xyzzy" {
  title = "Xyzzy"
}

resource "grafana_dashboard" "xyzzy" {
  folder      = grafana_folder.xyzzy.id
  config_json = file("${path.module}/../dashboards/dashboard.json")
}
