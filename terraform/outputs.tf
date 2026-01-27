# Outputs provide useful information after a successful 'terraform apply'
output "pubsub_topic_name" {
  description = "The name of the created Pub/Sub topic"
  value       = google_pubsub_topic.log_topic.name
}

output "pubsub_subscription_name" {
  description = "The name of the created Pub/Sub subscription"
  value       = google_pubsub_subscription.log_sub.name
}

output "storage_bucket_url" {
  description = "The URL of the created GCS bucket"
  value       = google_storage_bucket.log_bucket.url
}

output "service_account_email" {
  description = "The email of the dedicated service account for the app"
  value       = google_service_account.log_archiver_sa.email
}