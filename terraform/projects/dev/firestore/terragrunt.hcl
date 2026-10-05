include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

terraform {
  source = "../../../modules/cloud-firestore"
}

locals {
  envvars = read_terragrunt_config(find_in_parent_folders("envvars.hcl"))
}

inputs = {
  environment = "dev"
  project_id  = local.envvars.locals.gcp_dev_project_id
}
