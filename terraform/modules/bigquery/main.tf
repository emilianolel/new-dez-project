###############################################################################
# Módulo: BigQuery — Datasets para raw, staging y curated / analytics
###############################################################################

resource "google_bigquery_dataset" "raw" {
  dataset_id  = "${var.env}_raw"
  project     = var.project_id
  location    = var.region
  description = "Dataset de datos crudos - entorno ${var.env}"

  labels = {
    env   = var.env
    layer = "raw"
  }
}

resource "google_bigquery_dataset" "staging" {
  dataset_id  = "${var.env}_staging"
  project     = var.project_id
  location    = var.region
  description = "Dataset de datos transformados - entorno ${var.env}"

  labels = {
    env   = var.env
    layer = "staging"
  }
}

resource "google_bigquery_dataset" "analytics" {
  dataset_id  = "${var.env}_analytics"
  project     = var.project_id
  location    = var.region
  description = "Dataset de datos curados para analytics - entorno ${var.env}"

  labels = {
    env   = var.env
    layer = "analytics"
  }
}
