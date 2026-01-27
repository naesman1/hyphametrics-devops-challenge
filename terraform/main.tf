
# 1. Pub/Sub Resources
resource "google_pubsub_topic" "log_topic" {
  name = "log-archiver-topic"
}

resource "google_pubsub_subscription" "log_sub" {
  name  = "log-archiver-sub"
  topic = google_pubsub_topic.log_topic.name
  ack_deadline_seconds = 20
}

# 2. Storage Resources
resource "google_storage_bucket" "log_bucket" {
  name          = "${var.project_id}-log-archive-storage"
  location      = var.region
  storage_class = "STANDARD"
  public_access_prevention = "enforced"
  uniform_bucket_level_access = true
}

# 3. IAM Resources
resource "google_service_account" "log_archiver_sa" {
  account_id   = "log-archiver-sa"
  display_name = "Log Archiver Service Account"
}

# Permission to read/pull from the Pub/Sub subscription
resource "google_pubsub_subscription_iam_member" "subscriber_role" {
  subscription = google_pubsub_subscription.log_sub.name
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${google_service_account.log_archiver_sa.email}"
}

# Permission to write to the GCS bucket
resource "google_storage_bucket_iam_member" "writer_role" {
  bucket = google_storage_bucket.log_bucket.name
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:${google_service_account.log_archiver_sa.email}"
}