variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "telecom-dev-123"
}

variable "spanner_instance_id" {
  description = "Cloud Spanner Instance ID"
  type        = string
  default     = "telecom-spanner-dev"
}

variable "spanner_display_name" {
  description = "Cloud Spanner Instance Display Name"
  type        = string
  default     = "Telecom Spanner - Development"
}

variable "spanner_config" {
  description = "Cloud Spanner Instance Configuration (multi-region)"
  type        = string
  default     = "nam-eur-asia"
}

variable "spanner_nodes" {
  description = "Number of Spanner Nodes"
  type        = number
  default     = 3
}

variable "database_name" {
  description = "Cloud Spanner Database Name"
  type        = string
  default     = "telecom-db"
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "spanner_processing_units" {
  type        = number
  description = "Number of processing units for Spanner instance"
  default     = 3000
}
