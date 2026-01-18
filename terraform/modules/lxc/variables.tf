variable "proxmox_host_ip" {
  type        = string
  description = "The IP address of the Proxmox host for the CI provisioner."
}
variable "target_node" {}
variable "vmid" {}
variable "hostname" {}
variable "ostemplate" {}
variable "password" { default = "password" }
variable "cores" { default = 2 }
variable "memory" { default = 2048 }
variable "swap" { default = 512 }
variable "storage" { default = "local-lvm" }
variable "disk_size" { default = "8G" }
variable "bridge" { default = "vmbr0" }
variable "ssh_keys" {}
variable "container_id" {
  type        = number
  description = "The ID for the LXC container. If null, Proxmox will assign the next available ID."
  # default     = "102"
  # validation {
  #   condition     = var.ip_base == null || (var.ip_base != null && var.container_id != null)
  #   error_message = "If you specify an 'ip_prefix', you must also specify a 'container_id'."
  # }
}
variable "ip_base" {
  type        = string
  description = "The IP prefix for a static IP (e.g., '10.20.0'), setting a container_id is required for this. If null, DHCP will be used."
  default     = "10.10.10"
}

variable "cidr_suffix" {
  type        = string
  description = "The CIDR suffix for the network (e.g., '24' for /24)."
  default     = "24"
}

variable "gateway" {
  type        = string
  description = "The network gateway IP address. Required for static IP configuration. (e.g., 10.10.20.1)"
  default     = "10.10.10.1"
}
