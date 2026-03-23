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

## 🚀 Inicio rápido

### 1. Pre-requisitos

```bash
terraform --version   # >= 1.5.0
gcloud --version
gcloud auth login
```

### 2. Bootstrap (primera vez)

```bash
bash terraform/scripts/init.sh \
  MY_GCP_PROJECT_ID \
  my-tf-state-bucket \
  us-central1 \
  tu@email.com
```

Este comando hace todo automáticamente:
- Crea el bucket GCS para el estado de Terraform
- Crea la SA `terraform-admin` con los permisos necesarios
- Activa la impersonación en los providers

### 3. Desplegar infraestructura

```bash
# Solo dev
cd terraform/environments/dev && terraform init && terraform apply

# Solo prod
cd terraform/environments/prod && terraform init && terraform apply

# Ambos en paralelo
(cd terraform/environments/dev  && terraform apply -auto-approve) &
(cd terraform/environments/prod && terraform apply -auto-approve) &
wait
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
