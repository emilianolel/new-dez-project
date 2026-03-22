###############################################################################
# Entorno: DEV
# Este archivo invoca todos los módulos necesarios para el entorno de desarrollo
###############################################################################

module "networking" {
  source     = "../../modules/networking"
  project_id = var.project_id
  region     = var.region
  env        = var.env
}

module "iam" {
  source     = "../../modules/iam"
  project_id = var.project_id
  env        = var.env
}

module "secret_manager" {
  source     = "../../modules/secret_manager"
  project_id = var.project_id
  env        = var.env
}

module "gcs" {
  source     = "../../modules/gcs"
  project_id = var.project_id
  region     = var.region
  env        = var.env
}

module "bigquery" {
  source     = "../../modules/bigquery"
  project_id = var.project_id
  region     = var.region
  env        = var.env
}

module "pubsub" {
  source     = "../../modules/pubsub"
  project_id = var.project_id
  env        = var.env
}

module "artifact_registry" {
  source     = "../../modules/artifact_registry"
  project_id = var.project_id
  region     = var.region
  env        = var.env
}

module "cloud_functions" {
  source     = "../../modules/cloud_functions"
  project_id = var.project_id
  region     = var.region
  env        = var.env
}

module "dataflow" {
  source     = "../../modules/dataflow"
  project_id = var.project_id
  region     = var.region
  env        = var.env
}

module "composer" {
  source     = "../../modules/composer"
  project_id = var.project_id
  region     = var.region
  env        = var.env
}
