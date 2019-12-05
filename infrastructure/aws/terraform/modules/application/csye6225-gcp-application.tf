# Google PROFILE
provider "google" {
  project    = "${var.project}"
  region     = "${var.google_region}"
}

#Firewall
resource "google_compute_firewall" "ssh" {
  name    = "csye6225-firewall"
  network = "${var.network}"
  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "inbound" {
  name    = "csye6225-firewall1"
  network = "${var.network}"
  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "outbound" {
  name    = "csye6225-firewall2"
  network = "${var.network}"
  direction = "EGRESS"
  allow {
    protocol = "all"
  }
  destination_ranges = ["0.0.0.0/0"]
}

#Instance template
resource "google_compute_instance_template" "default" {
  project     = "${var.project}"
  name_prefix = "csye6225-"
  machine_type = "f1-micro"
  region = "${var.google_region}"
  tags = ["name", "webserver"]

  network_interface {
    network            = "${var.network}"
    subnetwork         = "${var.subnet_id1}"
    #subnetwork         = "10.0.1.0/24"
    subnetwork_project = "${var.project}"
    access_config{
    }
  }

  disk {
    auto_delete  = true
    boot         = true
    source_image = "projects/centos-cloud/global/images/family/centos-7"
    type         = "PERSISTENT"
    disk_type    = "pd-ssd"
    disk_size_gb = 20
    mode         = "READ_WRITE"
  }

  service_account {
    email  = "default"
    scopes = [
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write",
    "https://www.googleapis.com/auth/devstorage.full_control",
    ]
  }

  metadata = {
    ssh-keys = "${var.key_name}:${var.public_key_path}"
    startup-script = <<SCRIPT
        #! /bin/bash
        echo export TOMCAT_LOG_DIR=${var.tomcat_log_dir}>>/etc/profile
    SCRIPT
  }

  lifecycle {
    create_before_destroy = true
  }
}

#Autoscaler
resource "google_compute_autoscaler" "default" {
  name    = "csye6225-autoscaler"
  zone    = "${var.availability_zone1}"
  project = "${var.project}"
  target  = "${google_compute_instance_group_manager.default.self_link}"

  autoscaling_policy {
    max_replicas               = 10
    min_replicas               = 3
    cooldown_period            = 60
    cpu_utilization {
      target = 0.05
    }
  }
}

#Instance group manager
resource "google_compute_instance_group_manager" "default" {
  project            = "${var.project}"
  name               = "instance-gm"
  zone = "${var.availability_zone1}"
  description        = "compute VM Instance Group"
  wait_for_instances = false
  base_instance_name = "autoscaler-webserver"
  version {
    instance_template = "${google_compute_instance_template.default.self_link}"
    name             = "primary"
  }
  target_pools = ["${google_compute_target_pool.default.self_link}"]
}

#Target pool
resource "google_compute_target_pool" "default" {
  name = "csye6225-tp"
}

