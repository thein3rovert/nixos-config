variable "ssh_pub_key_file_path" {
  type = string
  default = "~/.ssh/id_ed25519"
}

variable "control_plane_ips" {
  type    = list(string)
}

variable "worker_ips" {
  type    = list(string)
}

variable "ssh_user" {
  type    = string
  default = "root"
}

variable "kube_api_loadbalancer_dns_name" {
  type    = string
  default = "k8s-auto"
}

variable "kube_api_server_port" {
  type    = string
  default = "6443"
}

variable "kube_vip_interface" {
  type    = string
  default = "eth0"
}

variable "kube_vip_enable" {
  type    = bool
  default = false
}


variable "kube_vip_address" {
  type    = string
}

## INCUS VM BASTION HOST
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
