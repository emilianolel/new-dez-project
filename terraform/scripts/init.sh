#!/usr/bin/env bash
###############################################################################
# init.sh — Bootstrap de Terraform para GCP Data Engineering
#
# Uso: bash scripts/init.sh <PROJECT_ID> <STATE_BUCKET> [REGION] [TU_EMAIL]
#
# Ejemplo:
#   bash scripts/init.sh my-project my-project-tf-state us-central1 tu@email.com
#
# Qué hace este script:
#   1. Autentica con tu cuenta personal (solo para el bootstrap)
#   2. Crea el bucket GCS de estado de Terraform con versioning
#   3. Actualiza todos los backend.tf con el nombre real del bucket
#   4. Actualiza todos los terraform.tfvars con el PROJECT_ID real
#   5. Aplica global/ con tu cuenta personal (crea la SA terraform-admin)
#   6. Activa la impersonación de la SA en los providers
###############################################################################

set -euo pipefail

PROJECT_ID="${1:?ERROR: Debes pasar el PROJECT_ID como primer argumento}"
STATE_BUCKET="${2:?ERROR: Debes pasar el nombre del bucket de estado como segundo argumento}"
REGION="${3:-us-central1}"
OPERATOR_EMAIL="${4:-}"

SA_NAME="terraform-admin"
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TERRAFORM_DIR="${SCRIPT_DIR}/.."

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "  🚀 Bootstrap de infraestructura GCP — Terraform Admin SA"
echo "════════════════════════════════════════════════════════════════"
echo ""

# ── PASO 1: Autenticación ────────────────────────────────────────────────────
echo "📋 PASO 1: Autenticando con tu cuenta personal..."
echo "   (Necesario solo para el bootstrap inicial)"

# Verifica si ya hay una cuenta activa en gcloud
ACTIVE_ACCOUNT="$(gcloud config get-value account 2>/dev/null || true)"
if [[ -z "${ACTIVE_ACCOUNT}" || "${ACTIVE_ACCOUNT}" == "(unset)" ]]; then
  echo "   No hay sesión activa. Abriendo login en el navegador..."
  gcloud auth login
else
  echo "   Sesión existente detectada: ${ACTIVE_ACCOUNT}"
fi

# Application Default Credentials (necesario para Terraform)
echo "   Configurando Application Default Credentials..."
gcloud auth application-default login

gcloud config set project "${PROJECT_ID}"
echo "   ✅ Autenticado como: $(gcloud config get-value account)"

# ── PASO 2: Bucket de estado ─────────────────────────────────────────────────
echo ""
echo "📦 PASO 2: Creando bucket de estado: gs://${STATE_BUCKET}"
gcloud storage buckets create "gs://${STATE_BUCKET}" \
  --project="${PROJECT_ID}" \
  --location="${REGION}" \
  --uniform-bucket-level-access 2>/dev/null || echo "   ℹ️  El bucket ya existe, continuando..."

gcloud storage buckets update "gs://${STATE_BUCKET}" --versioning
echo "   ✅ Bucket listo con versioning."

# ── PASO 3: Actualizar backend.tf ────────────────────────────────────────────
echo ""
echo "📝 PASO 3: Actualizando referencias al bucket en backend.tf..."
for BACKEND_FILE in \
  "${TERRAFORM_DIR}/global/backend.tf" \
  "${TERRAFORM_DIR}/environments/dev/backend.tf" \
  "${TERRAFORM_DIR}/environments/prod/backend.tf"; do
  
  if grep -q "REPLACE_WITH_YOUR_TERRAFORM_STATE_BUCKET" "${BACKEND_FILE}"; then
    sed -i.bak "s\|REPLACE_WITH_YOUR_TERRAFORM_STATE_BUCKET\|${STATE_BUCKET}\|g" "${BACKEND_FILE}"
    rm -f "${BACKEND_FILE}.bak"
    echo "   ✅ $(basename $(dirname ${BACKEND_FILE}))/backend.tf actualizado."
  else
    echo "   ℹ️  $(basename $(dirname ${BACKEND_FILE}))/backend.tf ya parece estar configurado."
  fi
done

# ── PASO 4: Actualizar terraform.tfvars ──────────────────────────────────────
echo ""
echo "📝 PASO 4: Actualizando PROJECT_ID y SA en .tfvars..."
for TFVARS_FILE in \
  "${TERRAFORM_DIR}/global/terraform.tfvars" \
  "${TERRAFORM_DIR}/environments/dev/terraform.tfvars" \
  "${TERRAFORM_DIR}/environments/prod/terraform.tfvars"; do
  
  if grep -q "YOUR_GCP_PROJECT_ID" "${TFVARS_FILE}"; then
    sed -i.bak "s\|YOUR_GCP_PROJECT_ID\|${PROJECT_ID}\|g" "${TFVARS_FILE}"
    rm -f "${TFVARS_FILE}.bak"
    echo "   ✅ $(basename $(dirname ${TFVARS_FILE}))/terraform.tfvars actualizado."
  else
    echo "   ℹ️  $(basename $(dirname ${TFVARS_FILE}))/terraform.tfvars ya tiene un PROJECT_ID configurado."
  fi
done

if [[ -n "${OPERATOR_EMAIL}" ]]; then
  sed -i.bak "s|tu@email.com|${OPERATOR_EMAIL}|g" "${TERRAFORM_DIR}/global/terraform.tfvars"
  rm -f "${TERRAFORM_DIR}/global/terraform.tfvars.bak"
  echo "   ✅ Operator: ${OPERATOR_EMAIL} añadido a terraform_operators"
fi

# ── PASO 5: Bootstrap de global/ (crea la SA terraform-admin) ────────────────
echo ""
echo "🏗️  PASO 5: Aplicando global/ — creando SA ${SA_EMAIL}..."
cd "${TERRAFORM_DIR}/global"
terraform init -reconfigure
terraform apply -auto-approve
echo "   ✅ SA ${SA_EMAIL} creada y roles asignados."

# ── PASO 6: Activar impersonación en global/backend.tf ───────────────────────
echo ""
echo "🔐 PASO 6: Activando impersonación en global/backend.tf..."
sed -i.bak \
  "s|# impersonate_service_account = \"terraform-admin@YOUR_PROJECT_ID.iam.gserviceaccount.com\"|impersonate_service_account = \"${SA_EMAIL}\"|g" \
  "${TERRAFORM_DIR}/global/backend.tf"
rm -f "${TERRAFORM_DIR}/global/backend.tf.bak"
echo "   ✅ Impersonación activada."

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "  ✅ Bootstrap completado"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "  SA de Terraform : ${SA_EMAIL}"
echo "  Bucket de estado: gs://${STATE_BUCKET}"
echo ""
echo "  Próximos pasos:"
echo ""
echo "  Desplegar DEV:"
echo "    cd terraform/environments/dev && terraform init && terraform apply"
echo ""
echo "  Desplegar PROD:"
echo "    cd terraform/environments/prod && terraform init && terraform apply"
echo ""
echo "  Desplegar ambos en paralelo:"
echo "    (cd terraform/environments/dev  && terraform apply -auto-approve) &"
echo "    (cd terraform/environments/prod && terraform apply -auto-approve) &"
echo "    wait && echo '✅ Ambos entornos desplegados'"
echo ""
