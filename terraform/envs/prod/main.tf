terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc07" # Using the required version
    }
  }
}

provider "proxmox" {
}

# module "ubuntu_container" {
#   source = "../../modules/lxc"
#
#   target_node = "thein3rovert"
#   hostname    = "ubuntu-ct-02"
#   template    = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
#   cores       = 2
#   memory      = 2048
#   disk_size   = "8G"
#   storage     = "local-lvm"
#   ssh_keys    = file("/home/thein3rovert/.ssh/id_ed25519.pub")
# }

module "ubuntu_container" {
  source = "../../modules/lxc"

  target_node = var.target_node
  password    = var.root_password
  hostname    = var.hostname
  vmid        = var.container_id
  ostemplate  = var.ostemplate
  cores       = 2
  memory      = 2048
  swap        = 512
  disk_size   = "8G"
  storage     = var.rootfs_storage
  ssh_keys    = file(var.ssh_public_key_path)

  # Override of default
  gateway         = var.gateway
  cidr_suffix     = var.cidr_suffix
  ip_base         = var.ip_base
  bridge          = var.bridge
  container_id    = var.container_id
  proxmox_host_ip = var.proxmox_host_ip
  extra_tags      = var.extra_tags

}

module "nixos_container_02" {
  source = "../../modules/lxc"

  target_node = var.target_node
  password    = var.root_password
  hostname    = "agent"
  vmid        = var.container_id
  ostemplate  = "local:vztmpl/nixos-image-lxc-proxmox-26.05.20251205.f61125a-x86_64-linux.tar.xz"
  cores       = 2
  memory      = 2048
  swap        = 512
  disk_size   = "8G"
  storage     = var.rootfs_storage
  ssh_keys    = file(var.ssh_public_key_path)

  # Override of default
  gateway         = var.gateway
  cidr_suffix     = var.cidr_suffix
  ip_base         = var.ip_base
  bridge          = var.bridge
  container_id    = 102
  proxmox_host_ip = var.proxmox_host_ip
  extra_tags      = ["nixos"]

}


