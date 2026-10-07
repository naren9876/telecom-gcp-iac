output "spanner_instance_id" {
  description = "Cloud Spanner Instance ID"
  value       = google_spanner_instance.telecom.name
}

output "spanner_connection_string" {
  description = "Cloud Spanner Connection String for Go Client"
  value       = "projects/${var.project_id}/instances/${google_spanner_instance.telecom.name}/databases/telecom-db"
}

output "spanner_instance_config" {
  description = "Cloud Spanner Instance Configuration"
  value       = var.spanner_config
}

output "spanner_nodes" {
  description = "Number of Spanner Nodes"
  value       = var.spanner_nodes
}
