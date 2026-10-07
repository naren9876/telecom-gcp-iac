include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

terraform {
  source = "../../../modules/cloud-spanner"
}

locals {
  envvars = read_terragrunt_config(find_in_parent_folders("envvars.hcl"))
}

inputs = {
  environment              = "dev"
  project_id               = local.envvars.locals.gcp_dev_project_id
  spanner_instance_id      = "telecom-spanner-dev"  # Will become telecom-spanner-dev
  spanner_database_id      = "telecom-db"
  spanner_config           = "regional-us-central1"
  spanner_processing_units = 3000
}
