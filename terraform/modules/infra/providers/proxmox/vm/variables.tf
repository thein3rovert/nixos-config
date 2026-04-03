variable "target_node" {
  type        = string
  description = "The name of the Proxmox node"
}

variable "kvm_enabled" {
  type        = bool
  description = "Enable KVM virtualization"
  default     = false
}

variable "hostname" {
  type        = string
  description = "The hostname for the VM"
}

variable "vmid" {
  type        = number
  description = "The VM ID"
}

variable "clone_template" {
  type        = string
  description = "Template to clone from"
  default     = null
}

variable "cores" {
  type        = number
  description = "Number of CPU cores"
  default     = 2
}

variable "sockets" {
  type        = number
  description = "Number of CPU sockets"
  default     = 1
}

variable "memory" {
  type        = number
  description = "Memory in MB"
  default     = 4096
}

variable "disk_size" {
  type        = string
  description = "Disk size (e.g., 20G)"
  default     = "20G"
}

variable "storage" {
  type        = string
  description = "Storage pool"
  default     = "local-lvm"
}

variable "bridge" {
  type        = string
  description = "Network bridge"
  default     = "vmbr0"
}

variable "ip_address" {
  type        = string
  description = "Static IP address (without CIDR)"
  default     = null
}

variable "cidr_suffix" {
  type        = string
  description = "CIDR suffix (e.g., 24)"
  default     = "24"
}

variable "gateway" {
  type        = string
  description = "Network gateway"
  default     = null
}

variable "password" {
  type        = string
  description = "Root password"
  sensitive   = true
}

variable "ssh_keys" {
  type        = string
  description = "SSH public keys"
}

variable "extra_tags" {
  type        = list(string)
  description = "Additional tags"
  default     = []
}

variable "agent_enabled" {
  type        = bool
  description = "Enable QEMU guest agent"
  default     = false
}

variable "description" {
  type        = string
  description = "VM description"
  default     = null
}
