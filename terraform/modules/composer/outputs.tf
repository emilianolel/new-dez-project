output "composer_gcs_bucket" { value = google_composer_environment.main.config[0].dag_gcs_prefix }
output "composer_airflow_uri" { value = google_composer_environment.main.config[0].airflow_uri }
