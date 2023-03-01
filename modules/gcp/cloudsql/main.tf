terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.49.0"
    }
  }
}

locals {
  sql_instance_name = "${var.env}-${var.name}"
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "${var.env}-private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.network_id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = var.network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_sql_database_instance" "this" {
  name             = local.sql_instance_name
  database_version = var.db_version
  region           = var.region

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = var.db_tier

    insights_config {
      query_insights_enabled  = true
      query_string_length     = 1024
      record_application_tags = true
      record_client_address   = true
    }

    ip_configuration {
      dynamic "authorized_networks" {
        for_each = var.authorized_networks
        content {
          name  = lookup(authorized_networks.value, "name", null)
          value = authorized_networks.value.value
        }
      }

      ipv4_enabled    = true
      private_network = var.network_id
    }
  }
  deletion_protection = var.deletion_protection
}

resource "google_sql_database" "this" {
  name     = var.db_name
  instance = google_sql_database_instance.this.name

  depends_on = [
    google_sql_database_instance.this
  ]
}

resource "google_sql_user" "user" {
  name     = var.db_user
  instance = google_sql_database_instance.this.name
  host     = var.db_host
  password = var.db_password

  depends_on = [
    google_sql_database_instance.this,
    google_sql_database.this
  ]
}
