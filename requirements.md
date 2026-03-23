# 📋 Requerimientos Generales del Proyecto

Para desplegar y gestionar esta infraestructura de forma exitosa, asegúrate de cumplir con los siguientes requisitos previos.

## 🛠️ Herramientas de Software

> [!TIP]
> Puedes intentar instalar estas herramientas automáticamente ejecutando:
> `bash terraform/scripts/install_requirements.sh`

| Herramienta | Versión Mínima | Función |
| :--- | :--- | :--- |
| **Terraform** | `1.5.0` | Orquestación de Infraestructura como Código (IaC). |
| **Google Cloud CLI** | `444.0.0` | Interfaz de línea de comandos para GCP (`gcloud`). |
| **Bash Shell** | `4.0` | Ejecución de scripts de automatización (`.sh`). |
| **curl** | *Cualquiera* | Consultas a la API de Facturación en el script de costos. |

> [!NOTE]
> Este proyecto ha sido probado principalmente en entornos **macOS** y **Linux**. En Windows, se recomienda usar **WSL2** para la ejecución de los scripts de Bash.

## 🔐 Google Cloud Platform (GCP)

### 1. Cuenta y Proyecto
*   Un **Proyecto de GCP** activo.
*   Una **Cuenta de Facturación** (Billing Account) vinculada al proyecto.
*   **APIs**: El usuario debe tener permisos para habilitar APIs (rol `Service Usage Admin` o `Owner`).

### 2. Permisos de Usuario
El usuario que ejecute los scripts iniciales debe contar con los siguientes roles (o ser `Owner` del proyecto):
*   `roles/resourcemanager.projectIamAdmin`: Para gestionar permisos de Service Accounts.
*   `roles/iam.serviceAccountAdmin`: Para crear la cuenta `terraform-admin`.
*   `roles/storage.admin`: Para crear el bucket de estado de Terraform.
*   `roles/serviceusage.serviceUsageAdmin`: Para habilitar las APIs necesarias.

## 🌐 Conectividad
*   Acceso a Internet sin restricciones para descargar los providers de Terraform (Hashicorp Registry).
*   Acceso a los endpoints de la API de Google Cloud (`*.googleapis.com`).

---
Para iniciar el despliegue, consulta la [Guía de Replicación en el README](./README.md#🚀-guía-de-replicación-paso-a-paso).
