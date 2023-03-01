terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.49.0"
    }
  }
}

locals {
  cluster_name = "${var.env}-${var.name}"
}

resource "google_container_cluster" "gke" {
  name     = local.cluster_name
  location = var.region

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  # remove_default_node_pool = true
  initial_node_count = var.initial_node_count

  network    = var.network_name
  subnetwork = var.public_subnet_name

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = ""
    services_ipv4_cidr_block = ""
  }

  node_config {
    disk_size_gb = var.disk_size_gb

    # # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    # service_account = google_service_account.default.email
    # oauth_scopes = [
    #   "https://www.googleapis.com/auth/cloud-platform"
    # ]
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only"
    ]

    labels = {
      env = var.env
    }
    tags = ["${local.cluster_name}-node"]
  }
  timeouts {
    create = "30m"
    update = "40m"
  }

}

# Separately Managed Node Pool
resource "google_container_node_pool" "gke-nodes" {
  name       = "${local.cluster_name}-node-pool"
  location   = var.region
  cluster    = local.cluster_name
  node_count = var.node_count

  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }

  management {
    auto_repair  = "true"
    auto_upgrade = "true"
  }

  lifecycle {
    create_before_destroy = false
  }

  node_config {
    disk_size_gb = var.disk_size_gb

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only"
    ]

    labels = {
      env = var.env
    }

    preemptible  = true
    machine_type = var.machine_type
    tags         = ["${local.cluster_name}-node"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  depends_on = [
    google_container_cluster.gke,
  ]
}
