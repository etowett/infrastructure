
resource "google_cloudbuild_trigger" "deploy_app" {
  for_each    = local.repos
  name        = "deploy-${each.key}"
  description = "Runs deploys for ${local.env}-${each.value.name}"
  filename    = each.value.filename
  #   service_account = google_service_account.cb_sa.name

  substitutions = {
    _STAGE = local.env
  }

  github {
    owner = "etowett"
    name  = each.value.name
    push {
      branch = "^main$"
    }
  }

  depends_on = [
    google_project_iam_member.act_as,
    google_project_iam_member.logs_writer
  ]

  disabled = false
}

resource "google_service_account" "cb_sa" {
  account_id = "${local.env}-cloudbuild-comms-sa"
}

resource "google_project_iam_member" "act_as" {
  project = local.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.cb_sa.email}"
}

resource "google_project_iam_member" "logs_writer" {
  project = local.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cb_sa.email}"
}
