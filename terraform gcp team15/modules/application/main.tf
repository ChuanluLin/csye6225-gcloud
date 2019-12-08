# CLOUD SQL (AWS_db_instance)
resource "google_sql_database_instance" "default" {
  name  = "csye6225"
  database_version = "MYSQL_5_7"
  region = "${var.region}"

  # Create a Private IP Instance
  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = "${var.dbnetwork.self_link}"
    }
  }
}

resource "google_sql_user" "users" {
  name     = "dbuser"
  instance = "${google_sql_database_instance.default.name}"
  password = "Qwer123!"
}

resource "google_compute_global_address" "private_ip_address" {

  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = "${var.dbnetwork.self_link}"
}

resource "google_service_networking_connection" "private_vpc_connection" {

  network = "${var.dbnetwork.self_link}"
  service = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

# PEER NETWORK
resource "google_compute_network_peering" "default" {
  name = "peering-default-db"
  network = "${var.network.self_link}"
  peer_network = "${var.dbnetwork.self_link}"
}

resource "google_compute_network_peering" "db" {
  name = "peering-db-default"
  network = "${var.dbnetwork.self_link}"
  peer_network = "${var.network.self_link}"
}

# CLOUD FILESTORE (aws_dynamodb)
resource "google_filestore_instance" "instance" {
  name = "csye6225"
  zone = "us-east1-b"
  tier = "STANDARD"

  file_shares {
    capacity_gb = 1024
    name        = "fileshare1"
  }

  networks {
    network = var.dbnetwork.name
    modes   = ["MODE_IPV4"]
  }
}

# INSTANCE TEMPLETE (aws_launch_configuration)
resource "google_compute_instance_template" "instance_template" {
  name_prefix = "instance-template-"
  machine_type = "f1-micro"
  region = "${var.region}"

# create a new disk source
  disk {
    auto_delete  = true
    boot         = true
    source_image = "projects/centos-cloud/global/images/family/centos-7"
    type         = "PERSISTENT"
    disk_type    = "pd-ssd"
    disk_size_gb = 20
    mode         = "READ_WRITE"
  }

# networking
  network_interface {
    subnetwork = "${var.subnet}"
  }

  lifecycle {
    create_before_destroy = true
  }

# aws iam instance profile
  service_account {
    email = "${format("%s@%s.iam.gserviceaccount.com", var.service_account_prefix, var.project)}"
    scopes = []
  }

# AWS user data
  metadata_startup_script = <<SCRIPT
        #! /bin/bash
        echo export TOMCAT_LOG_DIR=/home/centos>>/etc/profile
    SCRIPT
}

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

# Regional AUTOSCALER
resource "google_compute_region_autoscaler" "default" {
  name = "csye6225-region-autoscaler"
  region = "${var.region}"
  target = "${google_compute_region_instance_group_manager.default.self_link}"

  autoscaling_policy {
    max_replicas    = 10
    min_replicas    = 3
    cooldown_period = 60

    # based on CPU utilization
    cpu_utilization {
      target = 0.4
    }
  }
}

# INSTANCE GROUP MANAGER (aws_autoscaling_group)
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

# FIREWALL (aws ec2 instance security group)
resource "google_compute_firewall" "default" {
  name = "my-firewall"
  network = "${var.network.name}"
  
  allow { 
    protocol = "tcp"
    ports = ["80", "8080", "22", "443"]
  }

  # (The traffic source of AWS EC2 instance is load balancer)
  source_tags = ["web"]
}

# SSL
resource "google_compute_ssl_certificate" "default" {
  name_prefix = "my-certificate-"
  private_key = file("${path.module}/private.key")
  certificate = file("${path.module}/certificate.crt")

  lifecycle {
    create_before_destroy = true
  }
}

# LOAD BALANCER
resource "google_compute_target_https_proxy" "default" {
  name    = "${var.project}-https-proxy"
  url_map = google_compute_url_map.default.self_link

  ssl_certificates = [google_compute_ssl_certificate.default.self_link]
}

# FORWARDING RULE (aws_lb_listener)
resource "google_compute_global_forwarding_rule" "https" {
  name = "https-rule"
  target     = google_compute_target_https_proxy.default.self_link
  port_range = "443"
}

resource "google_compute_backend_service" "default" {
  name  = "backend-service"
  protocol = "HTTP"

  backend {
    group = "${google_compute_region_instance_group_manager.default.instance_group}"
  }

  health_checks = [google_compute_health_check.autohealing.self_link]

  security_policy = "${google_compute_security_policy.policy.self_link}"
}

# URL MAPPING
resource "google_compute_url_map" "default" {
  name = "url-map"
  default_service = "${google_compute_backend_service.default.self_link}"
  host_rule {
    hosts = ["mysite.com"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name = "allpaths"
    default_service = "${google_compute_backend_service.default.self_link}"

    path_rule {
      paths   = ["/*"]
      service = "${google_compute_backend_service.default.self_link}"
    }
  }
}

resource "google_storage_bucket" "default" {
  name = "${format("%s-bucket", var.project)}"
}

resource "google_storage_bucket_object" "archive" {
  name   = "csye6225-fa2019-object"
  bucket = "${google_storage_bucket.default.name}"
  source = "${path.module}/placeholder.zip"
}

# CLOUD FUNCTION (aws_lambda_function)
resource "google_cloudfunctions_function" "function" {
  name        = "pubsub-function"
  description = "The function to send emails"
  runtime     = "nodejs10"
  project     = "${var.project}"
  region      = "${var.region}"
  
  available_memory_mb   = 256
  source_archive_bucket = "${google_storage_bucket.default.name}"
  source_archive_object = "${google_storage_bucket_object.archive.name}"
  timeout               = 60
  entry_point           = "helloPubSub"

  event_trigger {
    event_type = "providers/cloud.pubsub/eventTypes/topic.publish"
    resource   = "${google_pubsub_topic.default.name}"
  }
}

# PUBSUB TOPIC (aws_sns_topic)
resource "google_pubsub_topic" "default" {
  name = "email_request"
}

# Set Pull Delivery for the Pub/Sub Topic
resource "google_pubsub_subscription" "pull" {
  project = "${var.project}"
  name    = "pull-subscription"
  topic   = "${google_pubsub_topic.default.name}"

  message_retention_duration = "1200s"
  retain_acked_messages      = true

  ack_deadline_seconds = 20

  expiration_policy {
    ttl = "300000.5s"
  }
}

# CLOUD ARMOR (aws_waf)
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

