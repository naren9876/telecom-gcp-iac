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

resource "google_project_service" "pubsub" {
  service            = "pubsub.googleapis.com"
  disable_on_destroy = false
}

resource "google_pubsub_topic" "telecom_events" {
  name = "telecom-events-${var.environment}"
  
  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }
  
  depends_on = [google_project_service.pubsub]
}

resource "google_pubsub_subscription" "telecom_events_sub" {
  name            = "telecom-events-${var.environment}-sub"
  topic           = google_pubsub_topic.telecom_events.name
  ack_deadline_seconds = 60
  
  depends_on = [google_pubsub_topic.telecom_events]
}

output "topic_name" {
  value = google_pubsub_topic.telecom_events.name
}
