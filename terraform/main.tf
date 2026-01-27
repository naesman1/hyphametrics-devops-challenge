
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
# 4. Artifact Registry
# Create the repository to store Docker images
resource "google_artifact_registry_repository" "app_repo" {
  project       = var.project_id
  location      = var.region
  repository_id = "log-archiver-repo"
  description   = "Docker repository for the log archiver app"
  format        = "DOCKER"
}

# Grant Artifact Registry Writer role to the Service Account
# This fixes the 'Permission denied' error during the CD push
resource "google_artifact_registry_repository_iam_member" "repo_writer" {
  location   = google_artifact_registry_repository.app_repo.location
  repository = google_artifact_registry_repository.app_repo.name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_service_account.log_archiver_sa.email}"
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