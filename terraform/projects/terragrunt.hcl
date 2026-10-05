locals {
  project_vars = read_terragrunt_config(find_in_parent_folders("envvars.hcl"))
}
