variable "project_id" {
  description = "ID del proyecto GCP"
  type        = string
}

variable "region" {
  description = "Región de GCP"
  type        = string
}

variable "env" {
  description = "Entorno (dev, prod)"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR de la subnet principal"
  type        = string
  default     = "10.0.0.0/24"
}
