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

resource "google_project_service" "bigtable" {
  service            = "bigtable.googleapis.com"
  disable_on_destroy = false
}

resource "google_bigtable_instance" "telecom" {
  name = "telecom-${var.environment}"
  
  cluster {
    cluster_id   = "telecom-${var.environment}-c1"
    zone         = var.region
    num_nodes    = var.bigtable_num_nodes
    storage_type = "SSD"
  }
  
  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }
  
  depends_on = [google_project_service.bigtable]
}

output "bigtable_instance_name" {
  value = google_bigtable_instance.telecom.name
}
