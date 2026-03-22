###############################################################################
# Módulo: IAM — Service Accounts y bindings para cada servicio
###############################################################################

# Service Account para Dataflow
resource "google_service_account" "dataflow" {
  account_id   = "${var.env}-sa-dataflow"
  display_name = "[${var.env}] Service Account - Dataflow"
  project      = var.project_id
}

# Service Account para Cloud Composer (Airflow)
resource "google_service_account" "composer" {
  account_id   = "${var.env}-sa-composer"
  display_name = "[${var.env}] Service Account - Composer"
  project      = var.project_id
}

# Service Account para Cloud Functions
resource "google_service_account" "cloud_functions" {
  account_id   = "${var.env}-sa-functions"
  display_name = "[${var.env}] Service Account - Cloud Functions"
  project      = var.project_id
}

# IAM bindings — Dataflow puede leer/escribir en GCS y BigQuery
resource "google_project_iam_member" "dataflow_worker" {
  project = var.project_id
  role    = "roles/dataflow.worker"
  member  = "serviceAccount:${google_service_account.dataflow.email}"
}

resource "google_project_iam_member" "dataflow_bigquery" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.dataflow.email}"
}

resource "google_project_iam_member" "dataflow_gcs" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.dataflow.email}"
}

# IAM bindings — Composer puede gestionar Dataflow y BigQuery
resource "google_project_iam_member" "composer_worker" {
  project = var.project_id
  role    = "roles/composer.worker"
  member  = "serviceAccount:${google_service_account.composer.email}"
}
