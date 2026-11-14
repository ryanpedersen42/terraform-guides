terraform {
  required_version = ">= 0.11.11"
}

provider "vault" {
  address = "${var.vault_addr}"
}

data "vault_generic_secret" "gcp_credentials" {
  path = "secret/${var.vault_user}/gcp/credentials"
}

provider "google" {
  credentials = "${data.vault_generic_secret.gcp_credentials.data[var.gcp_project]}"
  project     = "${var.gcp_project}"
  region      = "${var.gcp_region}"
}

resource "google_container_cluster" "k8sexample" {
  # Drata: Configure [google_container_cluster.node_config.labels] to ensure that organization-wide label conventions are followed.
  # Drata: Kubernetes provides an additional layer of security for sensitive data, such as Secrets, stored in etcd. Using this functionality, you can use a key managed by your Cloud provider to encrypt data at the etcd layer. This encryption protects against attackers who gain access to an offline copy of etcd. Ensure that [google_container_cluster.database_encryption.state] properties are correctly defined for encrypting secrets
  name               = "${var.vault_user}-k8s-cluster"
  description        = "example k8s cluster"
  zone               = "${var.gcp_zone}"
  initial_node_count = "${var.initial_node_count}"
  enable_kubernetes_alpha = "true"
  enable_legacy_abac = false

  master_auth {
    username = "${var.master_username}"
    password = "${var.master_password}"

    client_certificate_config {
      issue_client_certificate = true
    }
  }

  node_config {
    machine_type = "${var.node_machine_type}"
    disk_size_gb = "${var.node_disk_size}"
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring"
    ]
  }
}
