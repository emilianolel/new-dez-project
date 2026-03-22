###############################################################################
# Módulo: GCS — Data Lake con capas raw, staging y curated
###############################################################################

locals {
  bucket_prefix = "${var.project_id}-${var.env}"
}

resource "google_storage_bucket" "raw" {
  name                        = "${local.bucket_prefix}-raw"
  location                    = var.region
  project                     = var.project_id
  uniform_bucket_level_access = true
  force_destroy               = var.env == "dev" ? true : false

  lifecycle_rule {
    condition { age = 90 }
    action { type = "Delete" }
  }

  labels = {
    env   = var.env
    layer = "raw"
  }
}

resource "google_storage_bucket" "staging" {
  name                        = "${local.bucket_prefix}-staging"
  location                    = var.region
  project                     = var.project_id
  uniform_bucket_level_access = true
  force_destroy               = var.env == "dev" ? true : false

  labels = {
    env   = var.env
    layer = "staging"
  }
}

resource "google_storage_bucket" "curated" {
  name                        = "${local.bucket_prefix}-curated"
  location                    = var.region
  project                     = var.project_id
  uniform_bucket_level_access = true
  force_destroy               = false

  labels = {
    env   = var.env
    layer = "curated"
  }
}
