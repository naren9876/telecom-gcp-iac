variable "project_id" {
  type = string
}

variable "environment" {
  type = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Must be dev, staging, or prod"
  }
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "container_image" {
  type    = string
  default = "gcr.io/google-samples/hello-app:1.0"
}

variable "container_cpu" {
  type    = string
  default = "1"
}

variable "container_memory" {
  type    = string
  default = "512Mi"
}

variable "service_account_email" {
  type = string
}
