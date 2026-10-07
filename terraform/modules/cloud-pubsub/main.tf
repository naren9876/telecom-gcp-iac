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

resource "google_project_service" "pubsub" {
  service            = "pubsub.googleapis.com"
  disable_on_destroy = false
}

resource "google_pubsub_topic" "topics" {
  for_each = local.topics

  name                       = each.value.name
  message_retention_duration = var.message_retention_duration

  labels = {
    environment = var.environment
    project     = "telecom"
    phase       = "5"
  }

  depends_on = [google_project_service.pubsub]
}

resource "google_pubsub_topic" "deadletter" {
  name                       = local.dlq_topic_name
  message_retention_duration = var.message_retention_duration

  labels = {
    environment = var.environment
    project     = "telecom"
    phase       = "5"
    purpose     = "dead-letter-queue"
  }

  depends_on = [google_project_service.pubsub]
}

resource "google_pubsub_subscription" "subscriptions" {
  for_each = local.subscriptions

  name  = "${var.environment}-${each.key}"
  topic = google_pubsub_topic.topics[
    [for k, v in local.topics : k if v.name == each.value.topic][0]
  ].name

  ack_deadline_seconds = var.ack_deadline_seconds

  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.deadletter.id
    max_delivery_attempts = var.max_delivery_attempts
  }

  retry_policy {
    minimum_backoff = "10s"
    maximum_backoff = "600s"
  }

  labels = {
    environment = var.environment
    project     = "telecom"
    service     = each.value.service
  }

  depends_on = [google_pubsub_topic.topics, google_pubsub_topic.deadletter]
}

resource "google_pubsub_subscription" "deadletter" {
  name  = "${var.environment}-deadletter-sub"
  topic = google_pubsub_topic.deadletter.name

  ack_deadline_seconds = var.ack_deadline_seconds

  labels = {
    environment = var.environment
    project     = "telecom"
    purpose     = "dead-letter-queue"
  }

  depends_on = [google_pubsub_topic.deadletter]
}
