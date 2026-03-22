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

variable "vpc_network" {
  description = "Self-link de la VPC"
  type        = string
}

variable "vpc_subnetwork" {
  description = "ID de la subred"
  type        = string
}

variable "pod_range_name" {
  description = "Nombre del rango secundario para Pods"
  type        = string
  default     = "pods"
}

variable "service_range_name" {
  description = "Nombre del rango secundario para Servicios"
  type        = string
  default     = "services"
}

variable "master_ipv4_cidr" {
  description = "Rango de IP para el plano de control (Master)"
  type        = string
}

variable "composer_image_version" {
  description = "Versión de la imagen de Cloud Composer"
  type        = string
  default     = "composer-2.16.7-airflow-2.10.5"
}
