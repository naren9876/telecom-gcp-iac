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
  name             = var.spanner_instance_id
  display_name     = "Telecom Spanner - ${var.environment}"
  config           = var.spanner_config
  processing_units = var.spanner_processing_units

  labels = {
    environment = var.environment
    project     = "telecom"
    phase       = "4"
  }

  depends_on = [google_project_service.spanner]
}
