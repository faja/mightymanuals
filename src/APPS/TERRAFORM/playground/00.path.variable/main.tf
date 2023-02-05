terraform {}

output "path_module_in_root_config_path" {
  value = path.module
}

output "path_root_in_root_config_path" {
  value = path.root
}

module "path_module_inside_a_module" {
  source = "./modules/module1"
}

module "path_module_inside_a_module_from_git" {
  source = "git@github.com:faja/cautious-barnacle.git"
}
