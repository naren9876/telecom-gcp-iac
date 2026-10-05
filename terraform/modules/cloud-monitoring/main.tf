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

resource "google_project_service" "monitoring" {
  service            = "monitoring.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "logging" {
  service            = "logging.googleapis.com"
  disable_on_destroy = false
}

resource "google_monitoring_alert_policy" "spanner_cpu" {
  display_name = "Spanner CPU Alert - ${var.environment}"
  combiner     = "OR"
  
  conditions {
    display_name = "Spanner CPU > 80%"
    
    condition_threshold {
      filter          = "resource.type=\"spanner_instance\" AND metric.type=\"spanner.googleapis.com/instance/cpu/utilization\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.8
      
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }
  
  notification_channels = var.notification_channels
  
  depends_on = [google_project_service.monitoring]
}

output "alert_policy_name" {
  value = google_monitoring_alert_policy.spanner_cpu.name
}
