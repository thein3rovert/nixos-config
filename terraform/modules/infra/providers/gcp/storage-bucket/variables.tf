variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "bucket_name" {
  type        = string
  description = "Name of the storage bucket (must be globally unique)"
}

variable "location" {
  type        = string
  description = "Bucket location (use us-central1, us-east1, or us-west1 for Always Free)"
  default     = "us-central1"
}

variable "storage_class" {
  type        = string
  description = "Storage class (STANDARD, NEARLINE, COLDLINE, ARCHIVE)"
  default     = "STANDARD"
}

variable "versioning_enabled" {
  type        = bool
  description = "Enable versioning for the bucket"
  default     = true
}

variable "uniform_bucket_level_access" {
  type        = bool
  description = "Enable uniform bucket-level access"
  default     = true
}

variable "public_access_prevention" {
  type        = string
  description = "Prevents public access (enforced or inherited)"
  default     = "enforced"
}

variable "labels" {
  type        = map(string)
  description = "Labels to apply to the bucket"
  default     = {}
}

variable "lifecycle_rules" {
  type = list(object({
    action = object({
      type          = string
      storage_class = optional(string)
    })
    condition = object({
      age                   = optional(number)
      matches_storage_class = optional(list(string))
      num_newer_versions    = optional(number)
    })
  }))
  description = "Lifecycle rules for the bucket"
  default     = []
}

variable "force_destroy" {
  type        = bool
  description = "Allow deletion of non-empty bucket (use false for production)"
  default     = false
}
