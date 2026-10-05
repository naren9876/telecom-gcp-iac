terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
}

resource "google_service_account" "telecom" {
  account_id   = "telecom-${var.environment}"
  display_name = "Telecom Service Account - ${var.environment}"
  description  = "Service account for telecom platform"
}

resource "google_project_iam_member" "telecom_roles" {
  for_each = toset(var.service_account_roles)
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.telecom.email}"
}

output "service_account_email" {
  value = google_service_account.telecom.email
}
