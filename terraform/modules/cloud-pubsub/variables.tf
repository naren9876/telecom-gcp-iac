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

variable "message_retention_duration" {
  type        = string
  description = "How long to retain messages in topic (e.g., 604800s for 7 days)"
  default     = "604800s"
}

variable "ack_deadline_seconds" {
  type        = number
  description = "Seconds to wait for ack before redelivery"
  default     = 60
}

variable "max_delivery_attempts" {
  type        = number
  description = "Max delivery attempts before sending to dead letter"
  default     = 5
}

variable "api_gateway_service_account" {
  type        = string
  description = "Service account email for api-gateway microservice"
}

variable "order_service_service_account" {
  type        = string
  description = "Service account email for order-service microservice"
}

variable "user_service_service_account" {
  type        = string
  description = "Service account email for user-service microservice"
}
