# 🏗️ GCP Data Engineering Project

Proyecto de **ingeniería de datos en Google Cloud Platform**, gestionado como infraestructura como código (IaC) con **Terraform**. Define, versiona y despliega todos los servicios GCP necesarios para pipelines de datos end-to-end, con separación de entornos y gestión segura de accesos mediante Service Accounts.

---

## 🌐 Arquitectura general

```
                         ┌────────────────────────────────────────┐
                         │         Google Cloud Platform          │
                         │                                        │
  Fuentes externas       │  GCS (raw / staging / curated) ──────┐ │
  ───────────────► (API) │    │                         │       │ │
                         │    ▼                         ▼       │ │
                         │  Dataproc (Spark/Hadoop) ──► BigQuery │ │
                         │    │                                 │ │
                         │    ▼                                 ▼ │
                         │  Compute Engine (Ubuntu LTS Management VM) │
                         └────────────────────────────────────────┘
```

---

## 📁 Estructura del repositorio

```
.
├── .gitignore                  ← Excluye archivos sensibles y de estado
├── README.md                   ← Este archivo
└── terraform/
    ├── README.md               ← Documentación detallada de Terraform
    ├── global/                 ← APIs del proyecto + SA de administración
    ├── environments/
    │   ├── dev/                ← Infraestructura de desarrollo
    │   └── prod/               ← Infraestructura de producción
    ├── modules/                ← Módulos reutilizables por servicio GCP
    │   ├── gcs/                ← Data Lake (raw, staging, curated)
    │   ├── bigquery/           ← Data Warehouse (datasets por capa)
    │   ├── dataproc/           ← Procesamiento Spark/Hadoop
    │   ├── compute/            ← Instancia de gestión Ubuntu LTS
    │   ├── iam/                ← Service Accounts y permisos
    │   └── networking/         ← VPC, subnets, firewall
    └── scripts/
        ├── init.sh             ← Bootstrap automatizado (primera vez)
        ├── destroy.sh          ← Destrucción de infraestructura
        ├── audit.sh            ← Auditoría de recursos activos
        └── costs.sh            ← Reporte de gastos en USD
```

---

## ⚙️ Stack tecnológico

| Capa | Tecnología |
|---|---|
| **IaC** | Terraform ≥ 1.5 |
| **Cloud** | Google Cloud Platform |
| **Data Lake** | Cloud Storage (GCS) |
| **Data Warehouse** | BigQuery |
| **Procesamiento** | Dataproc (Spark/Hadoop) |
| **Gestión/VPC** | Compute Engine (Ubuntu) |
| **Seguridad** | IAM (Service Accounts) |
| **Red** | VPC personalizada con Cloud NAT |

---

## 🔐 Gestión de accesos

El proyecto usa **Service Account dedicada** (`terraform-admin`) para gestionar toda la infraestructura, en lugar de cuentas personales. El acceso funciona mediante **impersonación**:

```
Tu cuenta personal
 └── puede impersonar
       └── terraform-admin@PROJECT.iam.gserviceaccount.com
             └── gestiona GCS, BigQuery, Dataflow, Composer...
```

Esto significa que **ningún developer necesita roles de administrador** directamente en su cuenta GCP.

---

## 🚀 Guía de Replicación (Paso a Paso)

Sigue estos pasos para desplegar esta misma arquitectura en tu propia cuenta de GCP:

### 1. Preparación Local
Consulta los [Requerimientos Generales](./requirements.md) para verificar que tienes todo lo necesario (Terraform, gcloud, permisos).
Asegúrate de tener instalados [Terraform](https://developer.hashicorp.com/terraform/downloads) (≥ 1.5) y el [Google Cloud CLI](https://cloud.google.com/sdk/docs/install).

```bash
gcloud auth login
gcloud auth application-default login
```

### 2. Configuración de Variables
El repositorio incluye archivos `.example`. Debes crear tus archivos de configuración real:

```bash
# Global
cp terraform/global/terraform.tfvars.example terraform/global/terraform.tfvars

# Entornos
cp terraform/environments/dev/terraform.tfvars.example terraform/environments/dev/terraform.tfvars
cp terraform/environments/prod/terraform.tfvars.example terraform/environments/prod/terraform.tfvars
```

**IMPORTANTE**: Edita los nuevos archivos `.tfvars` y sustituye `TU_PROYECTO_ID` y `TU_EMAIL` por tus datos reales.

### 3. Inicialización Automática (Bootstrap)
Ejecuta el script de inicio para configurar la Service Account maestra y el almacenamiento del estado:

```bash
bash terraform/scripts/init.sh \
  EL_ID_DE_TU_PROYECTO \
  un-nombre-unico-para-tu-bucket-state \
  us-central1 \
  tu-email@dominio.com
```

### 4. Despliegue de Infraestructura
Una vez inicializado, despliega en este orden:

```bash
# 1. APIs y Permisos Globales
cd terraform/global && terraform init && terraform apply

# 2. Entorno de Desarrollo
cd ../environments/dev && terraform init && terraform apply

# 3. Entorno de Producción (Opcional)
cd ../prod && terraform init && terraform apply
```

### 5. Verificación
Usa los scripts de diagnóstico incluidos:
```bash
bash terraform/scripts/audit.sh  # Lista tus recursos activos
bash terraform/scripts/costs.sh  # Muestra el gasto estimado (USD)
```

---

## 📖 Documentación detallada

Consulta [`terraform/README.md`](./terraform/README.md) para:
- Guía paso a paso de despliegue
- Despliegue de módulos individuales con `-target`
- Flujo de trabajo recomendado (dev → prod)
- Comandos de diagnóstico y destrucción

---

## 🛡️ Seguridad y buenas prácticas

- **No se almacenan credenciales** en el repositorio (`.json`, `.auto.tfvars` excluidos por `.gitignore`)
- **Estado remoto cifrado** en GCS con versioning habilitado
- **Entornos aislados**: dev y prod tienen estados independientes, ningún cambio en uno afecta al otro
- **Principio de mínimo privilegio**: cada servicio tiene su propia Service Account con solo los roles necesarios
