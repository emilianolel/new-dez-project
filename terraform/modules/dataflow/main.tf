###############################################################################
# Módulo: Dataflow — Configuración de jobs de procesamiento batch/streaming
###############################################################################

# Bucket para templates y archivos temporales de Dataflow
resource "google_storage_bucket" "dataflow_temp" {
  name                        = "${var.project_id}-${var.env}-dataflow-temp"
  location                    = var.region
  project                     = var.project_id
  uniform_bucket_level_access = true
  force_destroy               = var.env == "dev" ? true : false

  labels = {
    env     = var.env
    service = "dataflow"
  }
}

# Nota: Los jobs de Dataflow se lanzan dinámicamente desde Airflow/Composer
# o mediante CI/CD. Aquí solo se provisiona la infraestructura base.
# Para crear un Dataflow job con Terraform usa: google_dataflow_job
# o google_dataflow_flex_template_job para Flex Templates.
