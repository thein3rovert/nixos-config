output "bucket_name" {
  value       = google_storage_bucket.bucket.name
  description = "The name of the bucket"
}

output "bucket_url" {
  value       = google_storage_bucket.bucket.url
  description = "The base URL of the bucket"
}

output "bucket_self_link" {
  value       = google_storage_bucket.bucket.self_link
  description = "The URI of the bucket"
}

output "bucket_location" {
  value       = google_storage_bucket.bucket.location
  description = "The location of the bucket"
}
