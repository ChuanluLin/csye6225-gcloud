resource "google_compute_network" "default" {
  name                    = "network-csye6225"
  auto_create_subnetworks = "false"
}

resource "google_compute_network" "database" {
  name                    = "network-db"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "subnet1" {
  name          = "subnet1-csye6225"
  ip_cidr_range = "10.2.0.0/16"
  region        = "${var.region}"
  network       = "${google_compute_network.default.self_link}"
}

resource "google_compute_subnetwork" "subnet2" {
  name          = "subnet2-csye6225"
  ip_cidr_range = "10.4.0.0/24"
  region        = "us-central1"
  network       = "${google_compute_network.default.self_link}"
}

