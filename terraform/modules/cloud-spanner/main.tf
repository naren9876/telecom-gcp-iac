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

# Enable Spanner API
resource "google_project_service" "spanner" {
  service            = "spanner.googleapis.com"
  disable_on_destroy = false
}

# Create Spanner Instance
resource "google_spanner_instance" "telecom" {
  name             = "telecom-${var.environment}"
  display_name     = "telecom-${var.environment}"
  config           = "multi-region-us-central1-us-east1"
  processing_units = var.spanner_processing_units
  
  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }
  
  depends_on = [google_project_service.spanner]
}

# Create Spanner Database
resource "google_spanner_database" "telecom" {
  instance             = google_spanner_instance.telecom.name
  name                 = "telecom-db-${var.environment}"
  version_retention_period = "3d"
  deletion_protection  = var.environment == "prod" ? true : false
  
  depends_on = [google_spanner_instance.telecom]
}

output "spanner_instance_id" {
  value       = google_spanner_instance.telecom.id
  description = "Spanner instance ID"
}

output "spanner_database_id" {
  value       = google_spanner_database.telecom.id
  description = "Spanner database ID"
}
