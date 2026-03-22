output "topic_name" { value = google_pubsub_topic.data_ingestion.name }
output "subscription_name" { value = google_pubsub_subscription.data_ingestion_sub.name }
