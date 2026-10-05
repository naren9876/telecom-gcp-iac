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

resource "google_project_service" "bigquery" {
  service            = "bigquery.googleapis.com"
  disable_on_destroy = false
}

resource "google_bigquery_dataset" "telecom" {
  dataset_id = "telecom_${replace(var.environment, "-", "_")}"
  location   = var.bigquery_region
  
  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }
  
  depends_on = [google_project_service.bigquery]
}

output "dataset_id" {
  value = google_bigquery_dataset.telecom.dataset_id
}
