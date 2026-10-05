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

resource "google_project_service" "firestore" {
  service            = "firestore.googleapis.com"
  disable_on_destroy = false
}

resource "google_firestore_database" "telecom" {
  name                = "(default)"
  location_id         = var.firestore_region
  type                = "FIRESTORE_NATIVE"
  concurrency_mode    = "OPTIMISTIC"
  delete_protection_enabled = var.environment == "prod" ? true : false
  
  depends_on = [google_project_service.firestore]
}

output "database_name" {
  value = google_firestore_database.telecom.name
}
