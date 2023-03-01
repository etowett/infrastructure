
resource "google_service_account_iam_member" "cicd_main_project_user" {
  service_account_id = google_service_account.main.id
  role               = "roles/iam.serviceAccountUser"

  member = "serviceAccount:${google_service_account.main_cicd.email}"

  depends_on = [
    google_service_account.main,
    google_service_account.main_cicd,
  ]
}

resource "google_service_account_iam_member" "cicd_main_project_token_creator" {
  service_account_id = google_service_account.main.id
  role               = "roles/iam.serviceAccountTokenCreator"

  member = "serviceAccount:${google_service_account.main_cicd.email}"

  depends_on = [
    google_service_account.main,
    google_service_account.main_cicd,
  ]
}

resource "google_service_account_iam_member" "user_cicd_user" {
  service_account_id = google_service_account.main_cicd.id
  role               = "roles/iam.serviceAccountUser"

  member = "user:${var.user_email}"

  depends_on = [
    google_service_account.main_cicd
  ]
}

resource "google_service_account_iam_member" "user_cicd_tokencreator" {
  service_account_id = google_service_account.main_cicd.id
  role               = "roles/iam.serviceAccountTokenCreator"

  member = "user:${var.user_email}"

  depends_on = [
    google_service_account.main_cicd
  ]
}
