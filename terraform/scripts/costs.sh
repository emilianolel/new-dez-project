#!/usr/bin/env bash
###############################################################################
# costs.sh — Reporte simplificado de costos en USD para un proyecto GCP
# Uso: bash scripts/costs.sh <PROJECT_ID> <mensual|anual>
###############################################################################

set -euo pipefail

PROJECT_ID="${1:?ERROR: Debes pasar el PROJECT_ID como primer argumento}"
PERIOD="${2:-mensual}"

echo "💰 Generando reporte de costos USD para: ${PROJECT_ID} (${PERIOD})"
echo "----------------------------------------------------------"

# 1. Obtener la Billing Account vinculada
BILLING_ACCOUNT=$(gcloud billing projects describe "${PROJECT_ID}" --format="value(billingAccountName)" --quiet 2>/dev/null || true)

if [[ -z "${BILLING_ACCOUNT}" ]]; then
  echo "❌ Error: No se pudo encontrar una cuenta de facturación vinculada a '${PROJECT_ID}'."
  echo "   O bien la cuenta no tiene permisos, o el comando requiere instalar componentes."
  echo "   Intentando método alternativo..."
  BILLING_ACCOUNT=$(gcloud billing accounts list --format="value(name)" --limit=1 --quiet 2>/dev/null || echo "")
fi

ACCOUNT_ID=$(basename "${BILLING_ACCOUNT}")
echo "📍 Billing Account detectada: ${ACCOUNT_ID}"

# 2. Definir fechas segun el periodo
# Usamos 'date' (macOS usa BSD date, Linux usa GNU date)
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Formato macOS (BSD)
    if [[ "$PERIOD" == "mensual" ]]; then
        START_DATE=$(date -v1d +"%Y-%m-%dT00:00:00Z")
    else
        START_DATE=$(date -v1d -v1m +"%Y-%m-%dT00:00:00Z")
    fi
    END_DATE=$(date +"%Y-%m-%dT23:59:59Z")
else
    # Formato Linux (GNU)
    if [[ "$PERIOD" == "mensual" ]]; then
        START_DATE=$(date -d "$(date +%Y-%m-01)" +"%Y-%m-%dT00:00:00Z")
    else
        START_DATE=$(date -d "$(date +%Y-01-01)" +"%Y-%m-%dT00:00:00Z")
    fi
    END_DATE=$(date +"%Y-%m-%dT23:59:59Z")
fi

# 3. Llamada a la API de Facturacion (Cloud Billing API)
# Nota: gcloud no da el monto directamente, usamos curl con el token de gcloud
TOKEN=$(gcloud auth print-access-token)

echo "⏳ Consultando servicios activos y costos estimados..."

# Intentamos obtener un resumen de presupuestos si existen (es el mejor proxy sin BQ)
BUDGETS=$(gcloud billing budgets list --billing-account="${ACCOUNT_ID}" --format="table(displayName, amount.specifiedAmount.units, currentSpend.amount.units)" 2>/dev/null || true)

if [[ -n "${BUDGETS}" ]]; then
    echo "📊 Presupuestos y Gasto Actual (Reportado por Budgets):"
    echo "${BUDGETS}"
else
    echo "⚠️  Aviso: No se encontraron Presupuestos (Budgets) definidos."
    echo "   Para reportes de costos mas granulares sin BigQuery, se recomienda:"
    echo "   1. Habilitar la exportación de gastos a BigQuery."
    echo "   2. Crear un presupuesto en el Billing de GCP para este proyecto."
fi

echo ""
echo "🔌 Auditoria de Servicios (Posibles generadores de costo):"
gcloud services list --project="${PROJECT_ID}" --enabled --filter="name:googleapis.com" --format="value(config.title)" | grep -E "Compute|Storage|BigQuery|Dataproc" | xargs -I {} echo "   - {} [ACTIVO]"

echo "----------------------------------------------------------"
echo "💡 Nota: Para obtener el MONTO EXACTO EN USD desglosado por servicio,"
echo "   Google requiere habilitar la exportacion a BigQuery. Una vez habilitada,"
echo "   puedes consultar la tabla 'billing_export' directamente."
echo "✅ Reporte finalizado."
