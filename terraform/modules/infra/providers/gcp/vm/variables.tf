variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "zone" {
  type        = string
  description = "GCP zone (e.g., us-central1-a)"
}

variable "instance_name" {
  type        = string
  description = "Name of the VM instance"
}

variable "machine_type" {
  type        = string
  description = "Machine type (e.g., e2-medium, n1-standard-1)"
  default     = "e2-medium"
}

variable "boot_disk_image" {
  type        = string
  description = "Boot disk image (e.g., debian-cloud/debian-11, ubuntu-os-cloud/ubuntu-2204-lts)"
  default     = "debian-cloud/debian-11"
}

variable "boot_disk_size" {
  type        = number
  description = "Boot disk size in GB"
  default     = 20
}

variable "boot_disk_type" {
  type        = string
  description = "Boot disk type (pd-standard, pd-balanced, pd-ssd)"
  default     = "pd-balanced"
}

variable "network" {
  type        = string
  description = "VPC network name"
  default     = "default"
}

variable "subnetwork" {
  type        = string
  description = "VPC subnetwork name"
  default     = null
}

variable "enable_external_ip" {
  type        = bool
  description = "Whether to assign an external IP address"
  default     = true
}

variable "static_external_ip" {
  type        = string
  description = "Static external IP address (leave null for ephemeral)"
  default     = null
}

variable "ssh_keys" {
  type        = string
  description = "SSH public keys in the format 'username:ssh-rsa AAAAB3...'"
  default     = ""
}

variable "tags" {
  type        = list(string)
  description = "Network tags for firewall rules"
  default     = []
}

variable "labels" {
  type        = map(string)
  description = "Resource labels"
  default     = {}
}

variable "metadata" {
  type        = map(string)
  description = "Custom metadata key-value pairs"
  default     = {}
}

variable "startup_script" {
  type        = string
  description = "Startup script to run on instance boot"
  default     = null
}

variable "allow_stopping_for_update" {
  type        = bool
  description = "Allow instance to be stopped for updates that require it"
  default     = true
}
