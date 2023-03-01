output "name" {
  description = "The name of the database instance"
  value       = google_sql_database_instance.this.name
}

output "public_ip_address" {
  description = "The public IPv4 address of the instance."
  value       = google_sql_database_instance.this.public_ip_address
}

output "private_ip_address" {
  description = "The public IPv4 address of the instance."
  value       = google_sql_database_instance.this.private_ip_address
}

output "ip_addresses" {
  description = "All IP addresses of the instance instance JSON encoded, see https://www.terraform.io/docs/providers/google/r/sql_database_instance.html#ip_address-0-ip_address"
  value       = jsonencode(google_sql_database_instance.this.ip_address)
}

output "self_link" {
  description = "Self link to the instance instance"
  value       = google_sql_database_instance.this.self_link
}
