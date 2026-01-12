variable "target_node" {}
variable "hostname" {}
variable "template" {}
variable "password" { default = "password" }
variable "cores" { default = 2 }
variable "memory" { default = 2048 }
variable "swap" { default = 512 }
variable "storage" { default = "local-lvm" }
variable "disk_size" { default = "8G" }
variable "bridge" { default = "vmbr0" }
variable "ip_config" { default = "dhcp" }
variable "ssh_keys" {}
