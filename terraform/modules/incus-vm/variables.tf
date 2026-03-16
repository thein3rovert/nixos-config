variable "vm_name" {
  description = "Name of the VM"
  type        = string
  default     = "ubuntu-vm"
}

variable "image" {
  description = "Image to use for the VM"
  type        = string
  default     = "images:ubuntu/24.04/cloud"
}

variable "cpu_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "memory_mb" {
  description = "Memory in MB"
  type        = number
  default     = 2048
}

variable "disk_size" {
  description = "Disk size (e.g., 20GB)"
  type        = string
  default     = "20GB"
}

variable "ssh_keys" {
  description = "SSH public keys to add to the VM"
  type        = list(string)
  default     = []
}
