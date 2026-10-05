output "network_id" {
  value = google_compute_network.telecom.id
}

output "subnet_id" {
  value = google_compute_subnetwork.telecom.id
}
