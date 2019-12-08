# Instance_template
resource "google_compute_instance_template" "instance_template" {
  name_prefix = "GCPdemo-"
  machine_type = "f1-micro"
  region = var.region
  tags = ["name", "webserver"]
  
  disk {
	auto_delete  = true
    boot         = true
    source_image = "projects/centos-cloud/global/images/family/centos-7"
    type         = "PERSISTENT"
    disk_type    = "pd-ssd"
    disk_size_gb = 20
    mode         = "READ_WRITE"
  }

  network_interface {
    network            = var.network
    subnetwork         = var.subnet_id1
    access_config{
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  service_account {
    email = "${format("gcpdemo@%s.iam.gserviceaccount.com", var.project)}"
    scopes = []
  }

  metadata_startup_script = ""

}

# resource "google_compute_target_pool" "appserver" {
  # name = "instance-pool"
# }

resource "google_compute_health_check" "autohealing" {
  name                = "autohealing-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10 # 50 seconds

  http_health_check {
    request_path = "/"
    port         = "80"
  }
}

resource "google_compute_region_autoscaler" "default" {
  name = "my-region-autoscaler"
  region = var.region
  target = google_compute_region_instance_group_manager.default.self_link

  autoscaling_policy {
    max_replicas    = 10
    min_replicas    = 3
    cooldown_period = 60

    # based on CPU utilization
    cpu_utilization {
      target = 0.4
    }

    # based on Stackdriver Monitoring
    # metric {
      # name = "compute.googleapis.com/instance/cpu/utilization"
      # filter = ""
      # single_instance_assignment = 65535
    # }
  }
}


# aws_autoscaling_group
resource "google_compute_region_instance_group_manager" "default" {
  name = "appserver-igm"
  region = var.region

  base_instance_name = "app"

  version {
    instance_template  = google_compute_instance_template.instance_template.self_link
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.autohealing.self_link
    initial_delay_sec = 300
  }
}

# aws ec2 instance security group
resource "google_compute_firewall" "default" {
  name = "my-firewall"
  network = var.network.name
  
  allow { 
    protocol = "tcp"
    ports = ["80", "8080", "22", "443"]
  }

  source_tags = ["web"]
}

resource "google_compute_ssl_certificate" "default" {
  name_prefix = "my-certificate-"
  private_key = file("${path.module}/private.key")
  certificate = file("${path.module}/certificate.crt")

  lifecycle {
    create_before_destroy = true
  }
}

# aws lb
resource "google_compute_target_https_proxy" "default" {
  name    = "${var.project}-https-proxy"
  url_map = google_compute_url_map.default.self_link

  ssl_certificates = [google_compute_ssl_certificate.default.self_link]
}

resource "google_compute_global_forwarding_rule" "https" {
  name = "https-rule"
  target     = google_compute_target_https_proxy.default.self_link
  port_range = "443"
}


resource "google_compute_backend_service" "default" {
  name  = "backend-service"
  protocol = "HTTPS"

  backend {
    group = google_compute_region_instance_group_manager.default.instance_group
  }

  health_checks = [google_compute_health_check.autohealing.self_link]

  security_policy = google_compute_security_policy.policy.self_link
}

resource "google_compute_url_map" "default" {
  name = "url-map"
  default_service = "${google_compute_backend_service.default.self_link}"
  host_rule {
    hosts = ["mysite.com"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name = "allpaths"
    default_service = google_compute_backend_service.default.self_link

    path_rule {
      paths   = ["/*"]
      service = google_compute_backend_service.default.self_link
    }
  }
}

# cloud armor
resource "google_compute_security_policy" "policy" {
  name = "my-policy"

  rule {
    action   = "deny(403)"
    priority = "1000"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["9.9.9.0/24"]
      }
    }
    description = "Deny access to IPs in 9.9.9.0/24"
  }

  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "default rule"
  }
}

