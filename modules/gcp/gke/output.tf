output "endpoint" {
  value = google_container_cluster.gke.endpoint
}

output "master_version" {
  value = google_container_cluster.gke.master_version
}

output "node_urls" {
  value = google_container_node_pool.gke-nodes.instance_group_urls
}
