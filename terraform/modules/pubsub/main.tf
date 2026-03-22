###############################################################################
# Módulo: Pub/Sub — Topics y subscriptions para ingesta de streaming
###############################################################################

resource "google_pubsub_topic" "data_ingestion" {
  name    = "${var.env}-data-ingestion"
  project = var.project_id

  labels = {
    env = var.env
  }

  message_retention_duration = "86400s" # 24 horas
}

resource "google_pubsub_subscription" "data_ingestion_sub" {
  name    = "${var.env}-data-ingestion-sub"
  project = var.project_id
  topic   = google_pubsub_topic.data_ingestion.name

  ack_deadline_seconds       = 60
  message_retention_duration = "600s"
  retain_acked_messages      = false

  expiration_policy {
    ttl = ""
  }

  labels = {
    env = var.env
  }
}
