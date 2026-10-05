locals {
  gcp_dev_project_id     = "telecom-dev-123"
  gcp_staging_project_id = "telecom-staging-456"
  gcp_prod_project_id    = "telecom-prod-789"
  
  gcs_terraform_bucket   = "telecom-terraform-state"
  gcs_terraform_prefix   = "telecom"
  
  github_repo            = "naren9876/telecom-gcp-platform"
}
