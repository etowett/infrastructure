terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.52.0"
    }
  }
}

locals {
  apis = [for api in [
    "compute",
    "container",
    "redis",
    "servicenetworking",
    "sqladmin",
    "secretmanager"
  ] : "${api}.googleapis.com"]

  cicd_apis = [for api in [
    "cloudbuild",
    "iam",
    "container",
    "compute",
    "cloudresourcemanager",
    "servicenetworking",
    "sqladmin",
  ] : "${api}.googleapis.com"]
}

resource "random_string" "random_suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "google_project" "main" {
  billing_account = var.billing_account
  name            = "${var.name} project"
  project_id      = "${var.name}-${random_string.random_suffix.result}"
}

resource "google_project" "main_cicd" {
  billing_account = var.billing_account
  name            = "${var.name} project cicd"
  project_id      = "${var.name}-cicd-${random_string.random_suffix.result}"
}

resource "google_project_service" "service" {
  for_each = toset(local.apis)
  project  = google_project.main.project_id
  service  = each.value

  disable_dependent_services = true
}

resource "google_project_service" "service_cicd" {
  for_each = toset(local.cicd_apis)
  project  = google_project.main_cicd.project_id
  service  = each.value

  disable_dependent_services = true
}

resource "google_service_account" "main" {
  project      = google_project.main.project_id
  account_id   = "${var.name}-sa"
  display_name = "SA for ${var.name}"

  depends_on = [
    google_project.main
  ]
}

resource "google_service_account" "main_cicd" {
  project      = google_project.main_cicd.project_id
  account_id   = "${var.name}-cicd-sa"
  display_name = "SA for ${var.name}-cicd"

  depends_on = [
    google_project.main_cicd
  ]
}

resource "google_storage_bucket" "tf_state" {
  project       = google_project.main.project_id
  name          = "citizix-${var.name}-tf-state"
  location      = var.location
  force_destroy = true

  public_access_prevention = "enforced"
}
