###############################################################################
# Global — Habilita las APIs de GCP y crea la Service Account de Terraform
###############################################################################

locals {
  project_id = var.project_id
  region     = var.region
}

# Habilita las APIs necesarias
resource "google_project_service" "apis" {
  for_each = toset(var.gcp_service_apis)

  project                    = local.project_id
  service                    = each.value
  disable_dependent_services = false
  disable_on_destroy         = false
}

###############################################################################
# Service Account de administración de Terraform
# Esta SA reemplaza el uso de cuentas personales para gestionar la infra.
# Se usa mediante impersonación: tu cuenta personal delega en esta SA.
###############################################################################

resource "google_service_account" "terraform_admin" {
  account_id   = "terraform-admin"
  display_name = "Terraform Admin — Gestión de infraestructura de datos"
  description  = "SA utilizada por Terraform para crear y gestionar todos los recursos del proyecto de datos."
  project      = local.project_id
}

# Roles necesarios para que la SA pueda gestionar todos los servicios del proyecto
locals {
  terraform_admin_roles = [
    "roles/bigquery.admin",
    "roles/storage.admin",
    "roles/dataflow.admin",
    "roles/pubsub.admin",
    "roles/composer.admin",
    "roles/cloudfunctions.admin",
    "roles/artifactregistry.admin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountTokenCreator",
    "roles/compute.admin",
    "roles/secretmanager.admin",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/iam.securityAdmin",
  ]
}

resource "google_project_iam_member" "terraform_admin_roles" {
  for_each = toset(local.terraform_admin_roles)

  project = local.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.terraform_admin.email}"
}

# Permite que tu cuenta personal (o grupo) impersone esta SA
# Sustituye var.terraform_operators por los emails que necesiten acceso
resource "google_service_account_iam_binding" "impersonation" {
  service_account_id = google_service_account.terraform_admin.name
  role               = "roles/iam.serviceAccountTokenCreator"
  members            = var.terraform_operators
}
