output "subnetwork" {
  value = "${google_compute_subnetwork.subnetwork1.name}"
}

output "network" {
  value = "${google_compute_network.vpc_network}"
}

output "dbnetwork" {
  value = "${google_compute_network.db_network}"
}
