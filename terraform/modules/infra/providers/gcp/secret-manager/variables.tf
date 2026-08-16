variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "secret_id" {
  type        = string
  description = "The secret ID (name) for the secret"
}

variable "secret_data" {
  type        = string
  description = "The secret data to store"
  sensitive   = true
}

variable "labels" {
  type        = map(string)
  description = "Labels to apply to the secret"
  default     = {}
}
