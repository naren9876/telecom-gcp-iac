output "topic_id" {
  value = google_pubsub_topic.telecom_events.id
}

output "subscription_id" {
  value = google_pubsub_subscription.telecom_events_sub.id
}
