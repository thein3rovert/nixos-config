variable "vm_name" {}
variable "target_node" {}
variable "template_name" {}
variable "cores" { default = 2 }
variable "memory" { default = 2048 }
variable "disk_size" { default = "15G" }
variable "storage" { default = "local-lvm" }
variable "bridge" { default = "vmbr0" }
variable "ip_config" { default = "ip=dhcp" }
variable "ci_user" { default = "ubuntu" }
variable "ssh_keys" {}
