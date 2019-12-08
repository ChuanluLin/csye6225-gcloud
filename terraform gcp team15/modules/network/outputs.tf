output "subnet" {
  value = "${google_compute_subnetwork.subnet1.name}"
}

output "network" {
  value = "${google_compute_network.default}"
}

output "dbnetwork" {
  value = "${google_compute_network.database}"
}
