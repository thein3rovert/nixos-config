terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc07"
    }
  }
}

resource "proxmox_vm_qemu" "ubuntu_vm" {
  name        = var.vm_name
  target_node = var.target_node
  clone       = var.template_name
  full_clone  = true

  kvm = false

  cpu {
    cores = var.cores
    type  = "qemu64"
  }
  memory = var.memory

  # Add this to force disk attachment
  disks {
    scsi {
      scsi0 {
        disk {
          size    = "10G"
          storage = var.storage
        }
      }
    }
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = var.bridge
  }

  os_type   = "cloud-init"
  ipconfig0 = var.ip_config
  ciuser    = var.ci_user
  sshkeys   = var.ssh_keys
}
