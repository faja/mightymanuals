terraform {}

locals {
  dashboards = [ for file in fileset(path.module, "templates/*.jsonnet") : file ]
}

output "dashboards" {
  value = local.dashboards
}

#
# NOTE!!!
#
# fileset produces list of files with path RELATIVE to
# its first argument, so in this example, the output will be
#
#  dashboards = [
#    "templates/dash1.jsonnet",
#    "templates/dash2.jsonnet",
#  ]
#
