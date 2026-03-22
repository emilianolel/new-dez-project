###############################################################################
# Módulo: Secret Manager — Gestión centralizada de secretos y credenciales
###############################################################################

# Secreto genérico de ejemplo (p.ej. API key de una fuente de datos)
resource "google_secret_manager_secret" "db_password" {
  secret_id = "${var.env}-db-password"
  project   = var.project_id

  replication {
    auto {}
  }

  labels = {
    env = var.env
  }
}

# Agrega más secretos según las necesidades del proyecto:
# - API keys de fuentes externas
# - Credenciales de bases de datos
# - Tokens de autenticación
