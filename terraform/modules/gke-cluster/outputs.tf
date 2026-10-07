output "cluster_name" {
  description = "GKE cluster name"
  value       = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  description = "GKE cluster endpoint"
  value       = google_container_cluster.primary.endpoint
  sensitive   = true
}

output "region" {
  description = "GCP region"
  value       = var.region
}

output "project_id" {
  description = "GCP Project ID"
  value       = var.project_id
}

output "kubernetes_cluster_host" {
  description = "Kubernetes cluster host"
  value       = "https://${google_container_cluster.primary.endpoint}"
  sensitive   = true
}

output "kubernetes_cluster_name" {
  description = "Kubernetes cluster name"
  value       = google_container_cluster.primary.name
}

output "workload_pool" {
  description = "Workload Identity pool"
  value       = "${var.project_id}.svc.id.goog"
}

output "services_node_pool_name" {
  description = "Services node pool name"
  value       = google_container_node_pool.services.name
}

output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region=${var.region} --project=${var.project_id}"
}
