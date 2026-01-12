terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc07" # Using the required version
}
  }
}

resource "proxmox_vm_qemu" "ubuntu_vm" {
  name        = var.vm_name
  target_node = var.target_node
  clone       = var.template_name
  
  cpu {
  cores   = var.cores
}
  memory  = var.memory
  
  disk {
    size    = var.disk_size
    type    = "disk"
    slot = "scsi1"
    storage = var.storage
  }
  
  network {
    id = 0
    model  = "virtio"
    bridge = var.bridge
  }
  
  os_type   = "cloud-init"
  ipconfig0 = var.ip_config
  ciuser    = var.ci_user
  sshkeys   = var.ssh_keys
}
