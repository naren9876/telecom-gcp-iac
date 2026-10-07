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

# Enable required APIs
resource "google_project_service" "gke" {
  service            = "container.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "compute" {
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

# GKE Cluster
resource "google_container_cluster" "primary" {
  name               = "${var.cluster_name}-${var.environment}"
  location           = var.region
  initial_node_count = 1

  deletion_protection = false

  # Network configuration
  network    = var.network_name
  subnetwork = google_compute_subnetwork.pods.name

  # Cluster configuration
  cluster_autoscaling {
    enabled = true
    resource_limits {
      resource_type = "cpu"
      minimum       = 1
      maximum       = 10
    }
    resource_limits {
      resource_type = "memory"
      minimum       = 1
      maximum       = 64
    }
  }

  # Workload Identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Network Policy
  network_policy {
    enabled  = var.enable_network_policy
    provider = "PROVIDER_UNSPECIFIED"
  }

  # Private cluster
  dynamic "private_cluster_config" {
    for_each = var.enable_private_cluster ? [1] : []
    content {
      enable_private_nodes    = true
      enable_private_endpoint = false
      master_ipv4_cidr_block  = "172.16.0.0/28"
    }
  }

  # Logging and Monitoring
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  labels = {
    environment = var.environment
    managed_by  = "terraform"
    phase       = "6"
  }

  depends_on = [
    google_project_service.gke,
    google_project_service.compute
  ]
}

# Node Pool for microservices
resource "google_container_node_pool" "services" {
  name           = "services"
  cluster        = google_container_cluster.primary.name
  location       = var.region
  node_count     = var.initial_node_count
  max_surge      = 1
  max_unavailable = 0

  autoscaling {
    min_node_count = 2
    max_node_count = 10
  }

  node_config {
    preemptible  = false
    machine_type = var.machine_type

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    labels = {
      workload = "services"
    }

    tags = ["telecom-gke", var.environment]
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

# VPC Subnetwork for pods
resource "google_compute_subnetwork" "pods" {
  name          = "telecom-pods-${var.environment}"
  ip_cidr_range = "10.0.0.0/16"
  region        = var.region
  network       = var.network_name

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.4.0.0/14"
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.8.0.0/20"
  }
}

# Firewall rule for internal communication
resource "google_compute_firewall" "internal" {
  name    = "telecom-gke-internal-${var.environment}"
  network = var.network_name

  allow {
    protocol = "tcp"
    ports    = ["443", "10250"]
  }

  source_ranges = ["10.0.0.0/8"]
  target_tags   = ["telecom-gke"]
}
