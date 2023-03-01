terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.49.0"
    }
  }
}

locals {
  vpc_name = "${var.env}-net"
}

resource "google_compute_network" "vpc" {
  name                    = local.vpc_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "public" {
  name          = "${local.vpc_name}-public-0"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = var.public_cidr_range
}

resource "google_compute_subnetwork" "private" {
  name                     = "${local.vpc_name}-private-0"
  region                   = var.region
  private_ip_google_access = true
  network                  = google_compute_network.vpc.name
  ip_cidr_range            = var.private_cidr_range
}
