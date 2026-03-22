#!/usr/bin/env bash
###############################################################################
# destroy.sh — Destruye la infraestructura de un entorno específico
# Uso: bash scripts/destroy.sh <ENV>   (env = dev | prod)
# ADVERTENCIA: Esta operación elimina recursos. Úsala con precaución en prod.
###############################################################################

set -euo pipefail

ENV="${1:?ERROR: Debes pasar el entorno como argumento (dev | prod)}"

if [[ "$ENV" == "prod" ]]; then
  echo "⚠️  ADVERTENCIA: Estás a punto de destruir el entorno de PRODUCCIÓN."
  read -r -p "¿Estás seguro? Escribe 'yes' para continuar: " confirm
  if [[ "$confirm" != "yes" ]]; then
    echo "❌ Operación cancelada."
    exit 0
  fi
fi

ENV_DIR="$(dirname "$0")/../environments/${ENV}"

if [[ ! -d "$ENV_DIR" ]]; then
  echo "❌ El entorno '${ENV}' no existe en terraform/environments/"
  exit 1
fi

echo "🗑️  Destruyendo entorno: ${ENV}"
cd "$ENV_DIR"
terraform destroy -auto-approve
echo "✅ Entorno ${ENV} destruido."
