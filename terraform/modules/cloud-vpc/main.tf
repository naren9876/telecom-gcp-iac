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

resource "google_project_service" "compute" {
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_network" "telecom" {
  name                    = "telecom-${var.environment}"
  auto_create_subnetworks = false
  
  depends_on = [google_project_service.compute]
}

resource "google_compute_subnetwork" "telecom" {
  name          = "telecom-${var.environment}-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.telecom.id
  
  private_ip_google_access = true
}

output "network_name" {
  value = google_compute_network.telecom.name
}
