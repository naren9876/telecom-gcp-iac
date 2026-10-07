locals {
  topics = {
    orders_created = {
      name        = "${var.environment}-orders.created"
      description = "Published when order is created"
    }
    orders_updated = {
      name        = "${var.environment}-orders.updated"
      description = "Published when order status changes"
    }
    payments_processed = {
      name        = "${var.environment}-payments.processed"
      description = "Published when payment completes"
    }
    users_registered = {
      name        = "${var.environment}-users.registered"
      description = "Published when new user registers"
    }
  }

  subscriptions = {
    orders_created_analytics = {
      topic          = local.topics.orders_created.name
      service        = "api-gateway"
      description    = "api-gateway subscribes to new orders"
      service_account = var.api_gateway_service_account
    }
    orders_created_user_service = {
      topic          = local.topics.orders_created.name
      service        = "user-service"
      description    = "user-service subscribes to new orders"
      service_account = var.user_service_service_account
    }
    orders_updated_api_gateway = {
      topic          = local.topics.orders_updated.name
      service        = "api-gateway"
      description    = "api-gateway subscribes to order updates"
      service_account = var.api_gateway_service_account
    }
    orders_updated_user_service = {
      topic          = local.topics.orders_updated.name
      service        = "user-service"
      description    = "user-service subscribes to order updates"
      service_account = var.user_service_service_account
    }
    payments_processed_order_service = {
      topic          = local.topics.payments_processed.name
      service        = "order-service"
      description    = "order-service subscribes to payment completion"
      service_account = var.order_service_service_account
    }
    payments_processed_api_gateway = {
      topic          = local.topics.payments_processed.name
      service        = "api-gateway"
      description    = "api-gateway subscribes to payment events"
      service_account = var.api_gateway_service_account
    }
    users_registered_order_service = {
      topic          = local.topics.users_registered.name
      service        = "order-service"
      description    = "order-service subscribes to new user registration"
      service_account = var.order_service_service_account
    }
    users_registered_api_gateway = {
      topic          = local.topics.users_registered.name
      service        = "api-gateway"
      description    = "api-gateway subscribes to new user registration"
      service_account = var.api_gateway_service_account
    }
  }

  dlq_topic_name = "${var.environment}-pubsub.deadletter"
}
