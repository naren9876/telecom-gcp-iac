output "topics" {
  description = "Map of all Pub/Sub topics"
  value = {
    for key, topic in google_pubsub_topic.topics : key => {
      name = topic.name
      id   = topic.id
    }
  }
}

output "topic_names" {
  description = "List of topic names"
  value = {
    orders_created     = google_pubsub_topic.topics["orders_created"].name
    orders_updated     = google_pubsub_topic.topics["orders_updated"].name
    payments_processed = google_pubsub_topic.topics["payments_processed"].name
    users_registered   = google_pubsub_topic.topics["users_registered"].name
  }
}

output "subscriptions" {
  description = "Map of all Pub/Sub subscriptions"
  value = {
    for key, sub in google_pubsub_subscription.subscriptions : key => {
      name = sub.name
      id   = sub.id
    }
  }
}

output "subscription_names" {
  description = "List of subscription names"
  value = {
    for key, sub in google_pubsub_subscription.subscriptions : key => sub.name
  }
}

output "pubsub_connection_strings" {
  description = "Pub/Sub connection info for microservices"
  value = {
    project_id = var.project_id
    topics = {
      orders_created     = "projects/${var.project_id}/topics/${google_pubsub_topic.topics["orders_created"].name}"
      orders_updated     = "projects/${var.project_id}/topics/${google_pubsub_topic.topics["orders_updated"].name}"
      payments_processed = "projects/${var.project_id}/topics/${google_pubsub_topic.topics["payments_processed"].name}"
      users_registered   = "projects/${var.project_id}/topics/${google_pubsub_topic.topics["users_registered"].name}"
    }
    subscriptions = {
      for key, sub in google_pubsub_subscription.subscriptions : key => {
        name = sub.name
        path = "projects/${var.project_id}/subscriptions/${sub.name}"
      }
    }
  }
}

output "deadletter_topic" {
  description = "Dead letter topic for failed messages"
  value = {
    name = google_pubsub_topic.deadletter.name
    id   = google_pubsub_topic.deadletter.id
  }
}

output "deadletter_subscription" {
  description = "Dead letter subscription"
  value = {
    name = google_pubsub_subscription.deadletter.name
    id   = google_pubsub_subscription.deadletter.id
  }
}
