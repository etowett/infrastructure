locals {
  roles = [
    "roles/storage.objectAdmin",
    "roles/compute.admin",
    "roles/compute.networkAdmin",
    "roles/container.clusterAdmin",
    "roles/container.admin",
    "roles/cloudsql.admin",
    "roles/redis.admin",
    "roles/storage.admin",
    "roles/iam.serviceAccountUser",
    "roles/iam.serviceAccountTokenCreator",
    "roles/owner",
  ]

  cicd_roles = [
    "roles/storage.admin",
    "roles/storage.objectAdmin",
    "roles/logging.logWriter",
    "roles/iam.serviceAccountUser",
    "roles/iam.serviceAccountTokenCreator",
  ]

  cloudbuild_roles = [
    "roles/container.clusterAdmin",
    "roles/container.admin",
  ]
}

resource "google_project_iam_member" "main_roles" {
  for_each = toset(local.roles)
  project  = google_project.main.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.main_cicd.email}"
}

resource "google_project_iam_member" "cicd_roles" {
  for_each = toset(local.cicd_roles)
  project  = google_project.main_cicd.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.main_cicd.email}"
}

resource "google_project_iam_member" "cloudbuild_roles" {
  for_each = toset(local.cloudbuild_roles)
  project  = google_project.main.project_id
  role     = each.value
  member   = "serviceAccount:164473244886@cloudbuild.gserviceaccount.com"
}
