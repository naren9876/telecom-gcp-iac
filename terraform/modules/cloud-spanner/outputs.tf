output "instance_name" {
  value       = google_spanner_instance.telecom.name
  description = "Spanner instance name"
}

output "database_name" {
  value       = google_spanner_database.telecom.name
  description = "Spanner database name"
}
