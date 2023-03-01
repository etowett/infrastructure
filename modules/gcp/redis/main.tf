terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.49.0"
    }
  }
}

locals {
  redis_name = "${var.env}-${var.name}-redis"
}

resource "google_compute_global_address" "service_range" {
  name          = "${local.redis_name}-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.network_id
}

resource "google_service_networking_connection" "private_service_connection" {
  network                 = var.network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.service_range.name]
}

resource "google_redis_instance" "redis" {
  name               = local.redis_name
  tier               = var.tier
  memory_size_gb     = var.memory_size_gb
  authorized_network = var.network_id
  region             = var.region
  location_id        = "${var.region}-b"
  redis_version      = var.redis_version
  auth_enabled       = true
  # connect_mode       = "PRIVATE_SERVICE_ACCESS"

  labels = {
    env  = var.env
    name = local.redis_name
  }

  depends_on = [google_service_networking_connection.private_service_connection]
}
