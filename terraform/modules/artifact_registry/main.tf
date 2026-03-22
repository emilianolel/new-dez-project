###############################################################################
# Módulo: Artifact Registry — Repositorio de imágenes Docker
###############################################################################

resource "google_artifact_registry_repository" "docker" {
  repository_id = "${var.env}-data-images"
  project       = var.project_id
  location      = var.region
  format        = "DOCKER"
  description   = "Repositorio de imágenes Docker para pipelines de datos - ${var.env}"

  labels = {
    env = var.env
  }
}
