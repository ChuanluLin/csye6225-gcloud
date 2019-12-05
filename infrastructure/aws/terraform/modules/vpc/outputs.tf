output "google_compute_network" {
  value = "${google_compute_network.csye6225-network.self_link}"
}

output "public_subnets_id1" {
  value = "${google_compute_subnetwork.csye6225-subnetwork.0.self_link}"
}

output "public_subnets_id2" {
  value = "${google_compute_subnetwork.csye6225-subnetwork.1.ip_cidr_range}"
}

output "public_subnets_id3" {
  value = "${google_compute_subnetwork.csye6225-subnetwork.2.ip_cidr_range}"
}

output "public_subnets_cidr_block" {
  value = "${join(", ", google_compute_subnetwork.csye6225-subnetwork.*.ip_cidr_range)}"
}