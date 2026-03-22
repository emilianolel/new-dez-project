###############################################################################
# Módulo: Cloud Composer — Entorno de Apache Airflow gestionado
###############################################################################

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
      network    = var.vpc_network
      subnetwork = var.vpc_subnetwork
    }

    environment_size = var.env == "prod" ? "ENVIRONMENT_SIZE_MEDIUM" : "ENVIRONMENT_SIZE_SMALL"
  }

  labels = {
    env = var.env
  }
}
