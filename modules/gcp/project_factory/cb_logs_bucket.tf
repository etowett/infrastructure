resource "google_storage_bucket" "cb_logs" {
  project                     = google_project.main_cicd.project_id
  location                    = var.location
  uniform_bucket_level_access = true
  name                        = "${var.name}-cb-logs"
  force_destroy               = true

  public_access_prevention = "enforced"

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 10
    }
  }
}

data "google_iam_policy" "cloudbuild_logs" {
  binding {
    role = "roles/storage.admin"
    members = [
      "serviceAccount:seed-service-account@super001-platform.iam.gserviceaccount.com"
    ]
  }
}

resource "google_storage_bucket_iam_policy" "cloudbuild-logs" {
  bucket      = google_storage_bucket.cloudbuild_logs.name
  policy_data = data.google_iam_policy.cloudbuild_logs.policy_data
}
