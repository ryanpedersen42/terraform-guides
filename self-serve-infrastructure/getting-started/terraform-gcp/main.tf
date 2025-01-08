provider "google" {
  project = "terraform-gcp-module-test"
  region  = "us-central1"
  project = "terraform-gcp-module-test"
}

resource "google_compute_network" "demo_network" {
  name                    = "${var.gn_name}"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "demo_subnetwork" {
  # Drata: Configure [google_compute_subnetwork.log_config] to ensure that security-relevant events are logged to detect malicious activity
  network       = "${google_compute_network.demo_network.name}"
  name          = "${var.sn_name}"
  region        = "${var.sn_region}"
  ip_cidr_range = "${var.sn_cidr_range}"
}
