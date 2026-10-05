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

resource "google_project_service" "kms" {
  service            = "cloudkms.googleapis.com"
  disable_on_destroy = false
}

resource "google_kms_key_ring" "telecom" {
  name     = "telecom-${var.environment}"
  location = var.kms_region
  
  depends_on = [google_project_service.kms]
}

resource "google_kms_crypto_key" "telecom" {
  name            = "telecom-key-${var.environment}"
  key_ring        = google_kms_key_ring.telecom.id
  rotation_period = "7776000s"
  
  depends_on = [google_kms_key_ring.telecom]
}

output "key_ring_name" {
  value = google_kms_key_ring.telecom.name
}
