resource "google_container_cluster" "primary" {
  name               = "${var.clusterName}"
  location           = "${var.region}"
  node_version       = "${var.clusterVersion}"
  min_master_version = "${var.clusterVersion}"
  initial_node_count = 1
  remove_default_node_pool = true

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  
  }
}
resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "pool1"
  location   = "${var.region}"
  cluster    = "${google_container_cluster.primary.name}"
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "${var.nodePoolSize}"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}