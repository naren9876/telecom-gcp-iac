resource "google_pubsub_topic_iam_member" "publishers" {
  for_each = {
    "orders_created_api_gateway" = {
      topic           = google_pubsub_topic.topics["orders_created"].name
      service_account = var.api_gateway_service_account
    }
    "users_registered_api_gateway" = {
      topic           = google_pubsub_topic.topics["users_registered"].name
      service_account = var.api_gateway_service_account
    }
    "orders_created_order_service" = {
      topic           = google_pubsub_topic.topics["orders_created"].name
      service_account = var.order_service_service_account
    }
    "orders_updated_order_service" = {
      topic           = google_pubsub_topic.topics["orders_updated"].name
      service_account = var.order_service_service_account
    }
    "users_registered_user_service" = {
      topic           = google_pubsub_topic.topics["users_registered"].name
      service_account = var.user_service_service_account
    }
    "payments_processed_user_service" = {
      topic           = google_pubsub_topic.topics["payments_processed"].name
      service_account = var.user_service_service_account
    }
  }

  topic  = each.value.topic
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:${each.value.service_account}"
}

resource "google_pubsub_subscription_iam_member" "subscribers" {
  for_each = local.subscriptions

  subscription = google_pubsub_subscription.subscriptions[each.key].name
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${each.value.service_account}"
}

resource "google_pubsub_subscription_iam_member" "subscription_editors" {
  for_each = {
    for key, sub in local.subscriptions : key => sub
    if sub.service_account != ""
  }

  subscription = google_pubsub_subscription.subscriptions[each.key].name
  role         = "roles/pubsub.editor"
  member       = "serviceAccount:${each.value.service_account}"
}

resource "google_pubsub_topic_iam_member" "deadletter_publisher" {
  for_each = toset([
    var.api_gateway_service_account,
    var.order_service_service_account,
    var.user_service_service_account
  ])

  topic  = google_pubsub_topic.deadletter.name
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:${each.value}"
}

resource "google_pubsub_subscription_iam_member" "deadletter_subscriber" {
  for_each = toset([
    var.api_gateway_service_account,
    var.order_service_service_account,
    var.user_service_service_account
  ])

  subscription = google_pubsub_subscription.deadletter.name
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${each.value}"
}
