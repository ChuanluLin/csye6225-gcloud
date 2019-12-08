#Vpcnetwork
resource "google_compute_network" "vpc_network" {
  name = "${var.vpc_name}-vpc"
  auto_create_subnetworks = "false"
}

#DBnetwork
resource "google_compute_network" "db_network" {
  name = "db-network"
  auto_create_subnetworks = "false"
}

#Subnetworks
resource "google_compute_subnetwork" "subnetwork1" {
  name   = "${var.vpc_name}-subnetwork1"
  ip_cidr_range = "${element(list(var.subnet1_cidr_block, var.subnet2_cidr_block)}"
  region = var.region
  network = google_compute_network.vpc_network.self_link
}

#Route
resource "google_compute_route" "public" {
  name        = "public-route"
  dest_range  = "0.0.0.0/0"
  network     = google_compute_network.csye6225-network.self_link
  next_hop_gateway = "default-internet-gateway"
}

