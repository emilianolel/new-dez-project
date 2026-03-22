variable "project_id"             { description = "ID del proyecto GCP"                  ; type = string }
variable "region"                 { description = "Región de GCP"                        ; type = string }
variable "env"                    { description = "Entorno (dev, prod)"                  ; type = string }
variable "vpc_network"            { description = "Self-link de la VPC"                  ; type = string }
variable "vpc_subnetwork"         { description = "Self-link de la subnet"               ; type = string }
variable "composer_image_version" { description = "Versión de la imagen de Composer"     ; type = string ; default = "composer-2-airflow-2" }
