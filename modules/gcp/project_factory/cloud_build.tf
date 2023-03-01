resource "google_cloudbuild_trigger" "plan_infra" {
  project         = google_project.main_cicd.project_id
  name            = "plan-${var.name}-infra"
  service_account = google_service_account.main_cicd.id
  description     = "Runs terraform plan on ${var.name}-infra"
  filename        = "/projects/gapps/infra/build/plan.yaml"

  included_files = [
    "projects/gapps/infra/${var.stage}/*.tf",
    "projects/gapps/infra/${var.stage}/*.tfvars",
    "projects/gapps/modules/**/*.tf",
  ]

  substitutions = {
    _DIR        = "projects/gapps/infra/${var.stage}"
    _LOG_BUCKET = google_storage_bucket.cb_logs.url
  }

  github {
    owner = "super001"
    name  = "infra"
    pull_request {
      branch = "^main$"
    }
  }

  disabled = false
}

resource "google_cloudbuild_trigger" "apply_infra" {
  project         = google_project.main_cicd.project_id
  name            = "apply-${var.name}-infra"
  service_account = google_service_account.main_cicd.id
  description     = "Runs terraform apply on ${var.name}-infra"
  filename        = "/projects/gapps/infra/build/apply.yaml"

  included_files = [
    "projects/gapps/infra/${var.stage}/*.tf",
    "projects/gapps/infra/${var.stage}/*.tfvars",
    "projects/gapps/modules/**/*.tf",
  ]

  substitutions = {
    _DIR        = "projects/gapps/infra/${var.stage}"
    _LOG_BUCKET = google_storage_bucket.cb_logs.url
  }

  github {
    owner = "super001"
    name  = "infra"
    push {
      branch = "^main$"
    }
  }

  disabled = false
}
