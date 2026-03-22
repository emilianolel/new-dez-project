# Valores globales del proyecto
project_id = "YOUR_GCP_PROJECT_ID"
region     = "us-central1"

# Lista de identidades (usuarios o grupos) autorizados a impersonar la SA de Terraform
# Reemplaza con tu email o el de tu equipo
terraform_operators = [
  "user:tu@email.com",
  # "group:data-engineers@tudominio.com",
]
