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

variable "static_ip" {
  description = "Static IP address for the VM (optional, uses DHCP if not set)"
  type        = string
  default     = null
}

variable "gateway" {
  description = "Network gateway (required if static_ip is set)"
  type        = string
  default     = null
}

variable "netmask" {
  description = "Network netmask (e.g., 255.255.255.0)"
  type        = string
  default     = "255.255.255.0"
}

variable "dns_servers" {
  description = "DNS servers"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}
