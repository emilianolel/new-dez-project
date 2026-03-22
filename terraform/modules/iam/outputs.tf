output "dataflow_sa_email" { value = google_service_account.dataflow.email }
output "composer_sa_email" { value = google_service_account.composer.email }
output "cloud_functions_sa_email" { value = google_service_account.cloud_functions.email }
