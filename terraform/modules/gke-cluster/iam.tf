# Kubernetes Service Account for microservices
resource "kubernetes_namespace" "telecom" {
  metadata {
    name = "telecom"
  }

  depends_on = [google_container_cluster.primary]
}

# Order Service KSA
resource "kubernetes_service_account" "order_service" {
  metadata {
    name      = "order-service"
    namespace = kubernetes_namespace.telecom.metadata[0].name
  }

  depends_on = [kubernetes_namespace.telecom]
}

# Payment Service KSA
resource "kubernetes_service_account" "payment_service" {
  metadata {
    name      = "payment-service"
    namespace = kubernetes_namespace.telecom.metadata[0].name
  }

  depends_on = [kubernetes_namespace.telecom]
}

# User Service KSA
resource "kubernetes_service_account" "user_service" {
  metadata {
    name      = "user-service"
    namespace = kubernetes_namespace.telecom.metadata[0].name
  }

  depends_on = [kubernetes_namespace.telecom]
}

# Workload Identity Binding for Order Service
resource "google_service_account" "order_service" {
  account_id   = "order-service-${var.environment}"
  display_name = "Order Service SA"
  project      = var.project_id
}

resource "google_service_account_iam_member" "order_service_wi" {
  service_account_id = google_service_account.order_service.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[telecom/order-service]"
}

# Workload Identity Binding for Payment Service
resource "google_service_account" "payment_service" {
  account_id   = "payment-service-${var.environment}"
  display_name = "Payment Service SA"
  project      = var.project_id
}

resource "google_service_account_iam_member" "payment_service_wi" {
  service_account_id = google_service_account.payment_service.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[telecom/payment-service]"
}

# Workload Identity Binding for User Service
resource "google_service_account" "user_service" {
  account_id   = "user-service-${var.environment}"
  display_name = "User Service SA"
  project      = var.project_id
}

resource "google_service_account_iam_member" "user_service_wi" {
  service_account_id = google_service_account.user_service.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[telecom/user-service]"
}

# Pub/Sub permissions for services
resource "google_pubsub_topic_iam_member" "order_publisher" {
  topic  = "projects/${var.project_id}/topics/${var.environment}-orders.created"
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:${google_service_account.order_service.email}"
}

resource "google_pubsub_subscription_iam_member" "order_subscriber" {
  subscription = "projects/${var.project_id}/subscriptions/${var.environment}-payments_processed_order_service"
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${google_service_account.order_service.email}"
}

# Spanner permissions
resource "google_spanner_instance_iam_member" "order_service" {
  instance = "telecom-spanner-${var.environment}"
  role     = "roles/spanner.databaseUser"
  member   = "serviceAccount:${google_service_account.order_service.email}"
}
