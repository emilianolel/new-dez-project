###############################################################################
# Módulo: Cloud Functions — Funciones serverless para triggers y procesamiento
###############################################################################

# Bucket donde se sube el código fuente de las funciones
resource "google_storage_bucket" "functions_source" {
  name                        = "${var.project_id}-${var.env}-functions-source"
  location                    = var.region
  project                     = var.project_id
  uniform_bucket_level_access = true
  force_destroy               = var.env == "dev" ? true : false

  labels = {
    env     = var.env
    service = "cloud-functions"
  }
}

# Ejemplo: Function de ingesta disparada por evento de GCS
# Descomenta y adapta cuando tengas el código fuente listo
#
# resource "google_cloudfunctions2_function" "gcs_trigger" {
#   name     = "${var.env}-gcs-ingest-trigger"
#   project  = var.project_id
#   location = var.region
#
#   build_config {
#     runtime     = "python311"
#     entry_point = "main"
#     source {
#       storage_source {
#         bucket = google_storage_bucket.functions_source.name
#         object = "gcs_trigger.zip"
#       }
#     }
#   }
#
#   service_config {
#     min_instance_count = 0
#     max_instance_count = 10
#     available_memory   = "256M"
#     environment_variables = {
#       ENVIRONMENT = var.env
#     }
#   }
# }
