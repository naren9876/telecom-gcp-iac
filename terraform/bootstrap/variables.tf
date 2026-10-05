variable "gcp_dev_project_id" {
  type        = string
  description = "GCP Project ID for DEV environment"
  
  validation {
    condition     = length(var.gcp_dev_project_id) > 0
    error_message = "GCP DEV Project ID cannot be empty"
  }
}

variable "gcp_staging_project_id" {
  type        = string
  description = "GCP Project ID for Staging environment"
  
  validation {
    condition     = length(var.gcp_staging_project_id) > 0
    error_message = "GCP Staging Project ID cannot be empty"
  }
}

variable "github_repo" {
  type        = string
  description = "GitHub repository for Workload Identity binding (format: owner/repo)"
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+/[a-zA-Z0-9_-]+$", var.github_repo))
    error_message = "GitHub repo must be in format: owner/repo"
  }
}
