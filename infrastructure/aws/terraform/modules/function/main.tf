resource "google_storage_bucket" "default" {
  name = "${format("%s-bucket", var.project)}"
}

resource "google_storage_bucket_object" "archive" {
  name   = "csye6225-fa009-object"
  bucket = google_storage_bucket.default.name
  source = "dummy.zip"
}

resource "google_cloudfunctions_function" "function" {
  name        = "email-function"
  description = "My function"
  runtime     = "nodejs8"
  project     = var.project
  region       = var.region
  
  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.default.name
  source_archive_object = google_storage_bucket_object.archive.name
  trigger_http          = true
  timeout               = 60
  entry_point           = "emailservice"
}

resource "google_pubsub_topic" "email" {
  name = "email"
}

resource "google_pubsub_subscription" "pull" {
  project = var.project
  name  = "pull-subscription"
  topic = google_pubsub_topic.email.name

  message_retention_duration = "1200s"
  retain_acked_messages      = true

  ack_deadline_seconds = 20

  expiration_policy {
    ttl = "300000.5s"
  }
}
