variable "project_id" {
  description = "ID del proyecto en GCP"
  type        = string
}

variable "region" {
  description = "Región principal de GCP"
  type        = string
  default     = "us-central1"
}

variable "env" {
  description = "Nombre del entorno (dev, prod)"
  type        = string
}

variable "terraform_admin_sa" {
  description = "Email de la SA terraform-admin usada para impersonación. Ejemplo: terraform-admin@PROJECT_ID.iam.gserviceaccount.com"
  type        = string
}
