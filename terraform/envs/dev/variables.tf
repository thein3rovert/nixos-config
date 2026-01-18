# variables.tf - Input variables for our Proxmox LXC module
variable "proxmox_host_ip" {
  type        = string
  description = "The IP address of the Proxmox host for the CI provisioner."
  default     = "10.10.10.8"
}
variable "rootfs_storage" {
  type        = string
  description = "The storage pool for the container's root disk (e.g., local-lvm)."
  default     = "local-lvm"
}
variable "root_password" {
  type        = string
  description = "The root password for the LXC container. Set to null for a random password."
  default     = "mypassword"
  sensitive   = true
}
variable "container_id" {
  type        = number
  description = "The ID for the LXC container. If null, Proxmox will assign the next available ID."
  default     = "103"
  validation {
    condition     = var.ip_base == null || (var.ip_base != null && var.container_id != null)
    error_message = "If you specify an 'ip_prefix', you must also specify a 'container_id'."
  }
}
variable "bridge" { default = "vmbr0" }

variable "hostname" {
  type        = string
  description = "The hostname for the new LXC container."
  default     = "thein3rovert-iac"
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

variable "target_node" {
  type        = string
  description = "The name of the target Proxmox node."
  default     = "thein3rovert"
}

variable "ostemplate" {
  type        = string
  description = "The name of the LXC template to use (e.g., 'local:vztmpl/alpine-3.22-default_20250617_amd64.tar.xz')."
  default     = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  # default     = "local:vztmpl/alpine-3.22-default_20250617_amd64.tar.xz"
}


variable "ssh_public_key_path" {
  type        = string
  description = "The path to the public SSH key to install in the container."
  default     = "~/.ssh/id_ed25519.pub"
}

variable "extra_tags" {
  description = "Additional tags to add to the container."
  type        = list(string)
  default     = ["dev"]
}

