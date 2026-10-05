terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  
  backend "gcs" {
    bucket = "telecom-dev-terraform-state"
    prefix = "bootstrap"
  }
}

provider "google" {
  project = var.gcp_dev_project_id
}

# Enable required APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "sts.googleapis.com",
  ])
  
  service            = each.value
  disable_on_destroy = false
}

# Workload Identity Pool for GitHub (DEV)
resource "google_iam_workload_identity_pool" "github_dev" {
  workload_identity_pool_id = "github"
  display_name              = "GitHub Actions"
  description               = "Workload Identity Pool for GitHub Actions CI/CD"
  
  depends_on = [google_project_service.required_apis]
}

# Workload Identity Pool Provider for GitHub (DEV)
resource "google_iam_workload_identity_pool_provider" "github_dev" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_dev.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub Provider"
  
  attribute_mapping = {
    "google.subject"              = "assertion.sub"
    "attribute.actor"             = "assertion.actor"
    "attribute.repository"        = "assertion.repository"
    "attribute.repository_owner"  = "assertion.repository_owner"
  }
  
  attribute_condition = "assertion.repository_owner == 'naren9876'"
  
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# Service account for Terraform (DEV)
resource "google_service_account" "terraform_dev" {
  account_id   = "telecom-dev-terraform"
  display_name = "Terraform Service Account - DEV"
  description  = "Service account for Terraform deployments in DEV"
}

# IAM bindings for Terraform service account (DEV)
resource "google_project_iam_member" "terraform_dev_roles" {
  for_each = toset([
    "roles/editor",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.workloadIdentityPoolAdmin",
    "roles/iam.workloadIdentityUser",
  ])
  
  project = var.gcp_dev_project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.terraform_dev.email}"
}

# Service account for CI/CD (DEV)
resource "google_service_account" "cicd_dev" {
  account_id   = "telecom-dev-cicd"
  display_name = "CI/CD Service Account - DEV"
  description  = "Service account for GitHub Actions CI/CD in DEV"
}

# IAM bindings for CI/CD service account (DEV)
resource "google_project_iam_member" "cicd_dev_roles" {
  for_each = toset([
    "roles/editor",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.workloadIdentityPoolAdmin",
    "roles/iam.workloadIdentityUser",
  ])
  
  project = var.gcp_dev_project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.cicd_dev.email}"
}

# Workload Identity binding for GitHub Actions - allow any repo owned by naren9876
resource "google_service_account_iam_binding" "cicd_dev_workload_identity" {
  service_account_id = google_service_account.cicd_dev.name
  role               = "roles/iam.workloadIdentityUser"
  
  members = [
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_dev.name}/attribute.repository_owner/naren9876",
  ]
}

output "workload_identity_provider_dev" {
  value = google_iam_workload_identity_pool_provider.github_dev.name
}

output "cicd_service_account_dev" {
  value = google_service_account.cicd_dev.email
}
