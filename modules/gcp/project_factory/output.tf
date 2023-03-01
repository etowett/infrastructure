
output "project_id" {
  value = google_project.main.project_id
}

output "cicd_project_id" {
  value = google_project.main_cicd.project_id
}

output "sa" {
  value = google_service_account.main.email
}

output "cicd_sa" {
  value = google_service_account.main_cicd.email
}

output "tf_state_bucket" {
  value = google_storage_bucket.tf_state.name
}
