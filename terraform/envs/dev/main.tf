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

#module "ubuntu_vm" {
#  source = "../../modules/cloud-init"
#  
#  vm_name       = "ubuntu-test"
#  target_node   = "thein3rovert"
#  template_name = "ubuntu-cloud-template"
#  cores         = 2
#  memory        = 2048
#  disk_size     = "15G"
#  storage       = "local-lvm"
#  ssh_keys      = file("/home/thein3rovert/.ssh/id_ed25519.pub")
#}


module "ubuntu_container" {
  source = "../../modules/lxc-container"

  target_node = "thein3rovert"
  hostname    = "ubuntu-ct-01"
  template    = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  cores       = 2
  memory      = 2048
  disk_size   = "8G"
  storage     = "local-lvm"
  ssh_keys    = file("/home/thein3rovert/.ssh/id_ed25519.pub")
}
