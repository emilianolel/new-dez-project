###############################################################################
# Módulo: Cloud Composer — Entorno de Apache Airflow gestionado
###############################################################################

# Service Account dedicada para el entorno de Composer (Requisito de Composer 2)
resource "google_service_account" "composer_worker" {
  account_id   = "${var.env}-composer-worker"
  display_name = "Composer Worker SA — ${var.env}"
  project      = var.project_id
}

# Los roles mínimos para que Composer 2 funcione y pase los health checks
locals {
  composer_worker_roles = [
    "roles/composer.worker",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/storage.objectViewer", # Necesario para leer imágenes de GCR/Artifact Registry
  ]
}

resource "google_project_iam_member" "composer_worker_roles" {
  for_each = toset(local.composer_worker_roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.composer_worker.email}"
}

# Permiso adicional: composer.ServiceAgent (necesario para que Composer gestione recursos)
# Nota: GCP suele crearlo automáticamente, pero es mejor asegurar roles básicos.

resource "google_composer_environment" "main" {
  name    = "${var.env}-composer"
  region  = var.region
  project = var.project_id

  config {
    software_config {
      image_version = var.composer_image_version
      env_variables = {
        ENVIRONMENT = var.env
      }
    }

    node_config {
      network         = var.vpc_network
      subnetwork      = var.vpc_subnetwork
      service_account = google_service_account.composer_worker.email
    }

    environment_size = var.env == "prod" ? "ENVIRONMENT_SIZE_MEDIUM" : "ENVIRONMENT_SIZE_SMALL"
  }

  labels = {
    env = var.env
  }
}
