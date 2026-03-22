###############################################################################
# Módulo: Networking — VPC, subnets y reglas de firewall
###############################################################################

resource "google_compute_network" "vpc" {
  name                    = "${var.env}-data-vpc"
  project                 = var.project_id
  auto_create_subnetworks = false
  description             = "VPC principal para entorno ${var.env}"
}

resource "google_compute_subnetwork" "data_subnet" {
  name          = "${var.env}-data-subnet"
  project       = var.project_id
  region        = var.region
  network       = google_compute_network.vpc.id
  ip_cidr_range = var.subnet_cidr

  private_ip_google_access = true
}

# Regla: permite tráfico interno dentro de la VPC
resource "google_compute_firewall" "internal" {
  name    = "${var.env}-allow-internal"
  project = var.project_id
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "icmp"
  }

  source_ranges = [var.subnet_cidr]
}
