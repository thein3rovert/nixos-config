variable "control_plane_ips" {
  type        = list(string)
  description = "List of control plane node IPs"
}

variable "ssh_user" {
  type        = string
  description = "SSH user for remote connections"
  default     = "root"
}

variable "ssh_private_key_path" {
  type        = string
  description = "Path to SSH private key"
  default     = "~/.ssh/id_ed25519"
}

variable "bastion_host" {
  type        = string
  description = "Bastion/jump host for SSH connections"
  default     = null
}

variable "bastion_user" {
  type        = string
  description = "SSH user for bastion host"
  default     = "root"
}

variable "bastion_port" {
  type        = number
  description = "SSH port for bastion host"
  default     = 22
}

variable "rancher_hostname" {
  type        = string
  description = "Hostname for Rancher UI"
  default     = "rancher.local"
}

variable "rancher_bootstrap_password" {
  type        = string
  description = "Bootstrap password for Rancher admin user"
  default     = "admin"
  sensitive   = true
}
