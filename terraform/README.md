# 🏗️ Infraestructura GCP — Data Engineering con Terraform

Infraestructura de datos en Google Cloud Platform definida como código (IaC) con Terraform. Incluye todos los servicios necesarios para pipelines de ingeniería de datos, organizados en módulos reutilizables y separados por entorno.

---

## 📁 Estructura de directorios

```
terraform/
├── environments/          # Configuraciones por entorno
│   ├── dev/               # Entorno de desarrollo
│   │   ├── backend.tf     # Backend remoto GCS + provider
│   │   ├── main.tf        # Invocación de módulos
│   │   ├── variables.tf   # Declaración de variables
│   │   ├── outputs.tf     # Outputs del entorno
│   │   └── terraform.tfvars
│   └── prod/              # Entorno de producción
│       └── ... (misma estructura)
│
├── modules/               # Módulos reutilizables por servicio GCP
│   ├── gcs/               # Data Lake (raw, staging, curated)
│   ├── bigquery/          # Datasets por capa de datos
│   ├── pubsub/            # Ingesta streaming (topics + subscriptions)
│   ├── dataflow/          # Procesamiento batch/streaming
│   ├── composer/          # Orquestación con Apache Airflow
│   ├── cloud_functions/   # Triggers serverless
│   ├── artifact_registry/ # Repositorio de imágenes Docker
│   ├── iam/               # Service Accounts y permisos
│   ├── networking/        # VPC, subnets, firewall
│   └── secret_manager/    # Gestión de secretos
│
├── global/                # APIs del proyecto (aplicar una sola vez)
│   ├── backend.tf
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars
│
└── scripts/
    ├── init.sh            # Crea el bucket de estado y muestra instrucciones
    └── destroy.sh         # Destruye infraestructura de un entorno
```

---

## 🧱 Servicios GCP incluidos

| Módulo | Servicio GCP | Función |
|---|---|---|
| `gcs` | Cloud Storage | Data Lake: buckets `raw`, `staging`, `curated` |
| `bigquery` | BigQuery | Data Warehouse: datasets por capa |
| `pubsub` | Pub/Sub | Ingesta de datos en tiempo real |
| `dataflow` | Dataflow | Procesamiento batch y streaming |
| `composer` | Cloud Composer | Orquestación de pipelines (Apache Airflow) |
| `cloud_functions` | Cloud Functions | Triggers y funciones serverless |
| `artifact_registry` | Artifact Registry | Imágenes Docker de pipelines |
| `iam` | IAM | Service Accounts y bindings de permisos |
| `networking` | VPC / Compute | Red privada, subnets, firewall |
| `secret_manager` | Secret Manager | Gestión de credenciales y secretos |

---

## 🚀 Guía de uso — Paso a paso

### 0. Pre-requisitos

```bash
# Verifica instalaciones requeridas
terraform -version    # >= 1.5.0
gcloud --version

# Autentícate con GCP
gcloud auth application-default login
gcloud config set project YOUR_GCP_PROJECT_ID
```

### 1. Crear el bucket de estado de Terraform (una sola vez)

El estado de Terraform se almacena remotamente en GCS. Debes crear el bucket **antes** de inicializar Terraform.

```bash
bash terraform/scripts/init.sh YOUR_GCP_PROJECT_ID your-tf-state-bucket us-central1
```

Luego actualiza el campo `bucket` en **todos** los archivos `backend.tf`:
```hcl
# terraform/global/backend.tf
# terraform/environments/dev/backend.tf
# terraform/environments/prod/backend.tf
backend "gcs" {
  bucket = "your-tf-state-bucket"   # ← Cambia esto
  prefix = "terraform/global"       # ← Cada entorno tiene su propio prefix
}
```

### 2. Habilitar APIs del proyecto (una sola vez)

El directorio `global/` habilita las APIs de GCP requeridas. Se aplica **una sola vez** y es independiente de los entornos.

```bash
cd terraform/global

# Edita terraform.tfvars con tu project_id real
nano terraform.tfvars

# Inicializa y aplica
terraform init
terraform plan
terraform apply
```

---

## 🔧 Desplegar un entorno específico

### Desplegar solo DEV

```bash
cd terraform/environments/dev

# Revisa y edita las variables del entorno
nano terraform.tfvars

# Inicializa el backend remoto
terraform init

# Previsualiza los cambios (sin aplicar nada)
terraform plan

# Aplica los cambios
terraform apply
```

### Desplegar solo PROD

```bash
cd terraform/environments/prod

nano terraform.tfvars

terraform init
terraform plan
terraform apply
```

> [!IMPORTANT]
> **DEV y PROD son completamente independientes.** Cada entorno tiene su propio estado remoto (prefix diferente en GCS) y sus propios recursos nombrados con el sufijo del entorno (ej: `dev-raw`, `prod-raw`). Desplegar uno **no afecta al otro**.

---

## ⚡ Desplegar ambos entornos en paralelo

Si necesitas desplegar (o actualizar) dev y prod al mismo tiempo, puedes ejecutarlos en paralelo desde terminales separadas o con un script:

### Opción A — Terminales paralelas

```bash
# Terminal 1 — DEV
cd terraform/environments/dev && terraform apply -auto-approve

# Terminal 2 — PROD (en otra terminal simultáneamente)
cd terraform/environments/prod && terraform apply -auto-approve
```

### Opción B — Script de despliegue paralelo

```bash
# Ejecuta apply en ambos entornos en paralelo y espera a que terminen
(cd terraform/environments/dev  && terraform apply -auto-approve) &
(cd terraform/environments/prod && terraform apply -auto-approve) &
wait
echo "✅ Ambos entornos desplegados."
```

> [!NOTE]
> Esto es seguro porque cada entorno tiene su propio estado remoto en GCS con un prefix distinto. No hay conflicto de estado entre entornos.

---

## 🗑️ Destruir infraestructura

### Destruir solo un entorno

```bash
# Destruir dev
bash terraform/scripts/destroy.sh dev

# Destruir prod (pedirá confirmación explícita)
bash terraform/scripts/destroy.sh prod
```

### Destruir manualmente desde el directorio

```bash
cd terraform/environments/dev
terraform destroy
```

> [!CAUTION]
> `terraform destroy` en `prod` elimina recursos reales. El script `destroy.sh` pide confirmación explícita al detectar el entorno `prod`.

---

## 🔄 Flujo de trabajo recomendado

```
1. Cambios en módulos → terraform plan en dev → revisar output
2. terraform apply en dev → validar funcionamiento
3. Si todo OK → terraform apply en prod
```

Nunca apliques cambios directamente en `prod` sin haberlos validado en `dev` primero.

---

## 📦 Desplegar un módulo específico (target)

Si solo quieres aplicar cambios en un módulo sin tocar el resto:

```bash
cd terraform/environments/dev

# Solo desplegar/actualizar GCS
terraform apply -target=module.gcs

# Solo desplegar BigQuery
terraform apply -target=module.bigquery

# Solo IAM y Networking
terraform apply -target=module.iam -target=module.networking
```

---

## 🔍 Comandos útiles

```bash
# Ver el estado actual de la infra de dev
cd terraform/environments/dev
terraform show

# Ver outputs del entorno
terraform output

# Ver el plan sin aplicar
terraform plan -out=tfplan.binary
terraform show -json tfplan.binary | jq

# Formatear todos los archivos .tf
terraform fmt -recursive terraform/

# Validar la sintaxis HCL
terraform validate
```

---

## 🗺️ Variables clave por entorno

| Variable | Descripción | Ejemplo dev | Ejemplo prod |
|---|---|---|---|
| `project_id` | ID del proyecto GCP | `my-project-dev` | `my-project-prod` |
| `region` | Región de despliegue | `us-central1` | `us-central1` |
| `env` | Nombre del entorno | `dev` | `prod` |

---

## 📌 Convención de nombres de recursos

Todos los recursos siguen la convención `{env}-{recurso}` o `{project_id}-{env}-{recurso}`:

```
dev-data-vpc             ← VPC de dev
prod-data-vpc            ← VPC de prod
my-project-dev-raw       ← Bucket GCS raw de dev
my-project-prod-raw      ← Bucket GCS raw de prod
dev_raw                  ← Dataset BigQuery raw de dev
prod_analytics           ← Dataset BigQuery analytics de prod
```

Esto garantiza que ambos entornos coexistan en el mismo proyecto GCP sin conflictos de nombres.
