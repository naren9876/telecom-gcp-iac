locals {
  project_vars = read_terragrunt_config(find_in_parent_folders("envvars.hcl"))
}

include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

inputs = {
  project_id  = local.project_vars.locals.gcp_prod_project_id
  environment = "prod"
}
