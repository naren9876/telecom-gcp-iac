locals {
  project_vars = read_terragrunt_config(find_in_parent_folders("envvars.hcl"))
  
  gcp_dev_project_id     = local.project_vars.locals.gcp_dev_project_id
  gcp_staging_project_id = local.project_vars.locals.gcp_staging_project_id
  gcp_prod_project_id    = local.project_vars.locals.gcp_prod_project_id
}

remote_state {
  backend = "gcs"
  config = {
    bucket         = "telecom-terraform-state"
    prefix         = "telecom/${path_relative_to_include()}"
    location       = "us-central1"
    encryption_key = ""
  }
}
