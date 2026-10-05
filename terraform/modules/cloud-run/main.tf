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

resource "google_project_service" "cloudrun" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

resource "google_cloud_run_service" "telecom" {
  name     = "telecom-api-${var.environment}"
  location = var.region
  
  template {
    spec {
      containers {
        image = var.container_image
        
        resources {
          limits = {
            cpu    = var.container_cpu
            memory = var.container_memory
          }
        }
        
        env {
          name  = "ENVIRONMENT"
          value = var.environment
        }
      }
      
      service_account_name = var.service_account_email
    }
  }
  
  depends_on = [google_project_service.cloudrun]
}

resource "google_cloud_run_service_iam_member" "public" {
  service  = google_cloud_run_service.telecom.name
  location = google_cloud_run_service.telecom.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

output "service_url" {
  value = google_cloud_run_service.telecom.status[0].url
}
