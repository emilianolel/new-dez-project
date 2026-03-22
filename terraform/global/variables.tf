variable "project_id" {
  description = "ID del proyecto en GCP"
  type        = string
}

variable "region" {
  description = "Región principal de GCP"
  type        = string
  default     = "us-central1"
}

variable "gcp_service_apis" {
  description = "Lista de APIs de GCP a habilitar"
  type        = list(string)
  default = [
    "bigquery.googleapis.com",
    "storage.googleapis.com",
    "dataflow.googleapis.com",
    "pubsub.googleapis.com",
    "composer.googleapis.com",
    "cloudfunctions.googleapis.com",
    "artifactregistry.googleapis.com",
    "secretmanager.googleapis.com",
    "iam.googleapis.com",
    "compute.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iamcredentials.googleapis.com",
  ]
}

variable "terraform_operators" {
  description = <<-EOT
    Lista de identidades que pueden impersonar la SA terraform-admin.
    Formato: ["user:tu@email.com", "group:equipo@dominio.com"]
    Estas identidades podrán ejecutar Terraform localmente o en CI/CD
    sin necesitar roles de administrador directamente en su cuenta.
  EOT
  type        = list(string)
}
