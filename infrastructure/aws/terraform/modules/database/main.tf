resource "google_sql_database_instance" "master" {
  name  = "csye6225"
  database_version = "MYSQL_5_6"
  region = var.region

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.dbnetwork.self_link
    }
  }
}

resource "google_sql_user" "users" {
  name     = "dbuser"
  instance = google_sql_database_instance.master.name
  password = "A0zxcvasdf"
}


resource "google_compute_global_address" "private_ip_address" {

  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.dbnetwork.self_link
}

resource "google_service_networking_connection" "private_vpc_connection" {

  network = var.dbnetwork.self_link
  service = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_compute_network_peering" "peering1" {
  name = "peering1"
  network = var.network.self_link
  peer_network = var.dbnetwork.self_link
}


resource "google_filestore_instance" "instance" {
  name = "csye6225"
  zone = "us-east1-b"
  tier = "STANDARD"

  file_shares {
    capacity_gb = 2660
    name        = "share1"
  }

  networks {
    network = var.dbnetwork.name
    modes   = ["MODE_IPV4"]
  }
}
