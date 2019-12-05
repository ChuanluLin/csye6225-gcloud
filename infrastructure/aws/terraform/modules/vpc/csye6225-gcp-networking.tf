# Google PROFILE
provider "google" {
  project    = "${var.project}"
  region     = "${var.google_region}"
}

#VPC
resource "google_compute_network" "csye6225-network" {
  name                    = "csye6225-network"
  routing_mode            = "REGIONAL"
  auto_create_subnetworks = false
}

#Subnets
resource "google_compute_subnetwork" "csye6225-subnetwork" {
  count         = "${var.subnet_count}"
  name          = "public${count.index}"
  ip_cidr_range = "${element(list(var.subnet1_cidr_block, var.subnet2_cidr_block, var.subnet3_cidr_block), count.index)}"
  region        = "${var.google_region}"
  network       = google_compute_network.csye6225-network.self_link
  depends_on    = [google_compute_network.csye6225-network]
}

#Route
resource "google_compute_route" "public" {
  name        = "public-route"
  dest_range  = "0.0.0.0/0"
  network     = google_compute_network.csye6225-network.self_link
  next_hop_gateway = "default-internet-gateway"
}