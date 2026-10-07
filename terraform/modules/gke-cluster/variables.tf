variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod"
  }
}

variable "region" {
  type        = string
  description = "GCP region"
  default     = "us-central1"
}

variable "cluster_name" {
  type        = string
  description = "GKE cluster name"
  default     = "telecom-gke"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version"
  default     = "1.27"
}

variable "initial_node_count" {
  type        = number
  description = "Initial node count"
  default     = 3
}

variable "machine_type" {
  type        = string
  description = "Machine type for nodes"
  default     = "n1-standard-2"
}

variable "enable_private_cluster" {
  type        = bool
  description = "Enable private cluster"
  default     = true
}

variable "enable_workload_identity" {
  type        = bool
  description = "Enable Workload Identity"
  default     = true
}

variable "network_name" {
  type        = string
  description = "VPC network name"
  default     = "default"
}

variable "enable_network_policy" {
  type        = bool
  description = "Enable network policy"
  default     = true
}

variable "enable_binary_authorization" {
  type        = bool
  description = "Enable binary authorization"
  default     = false
}
