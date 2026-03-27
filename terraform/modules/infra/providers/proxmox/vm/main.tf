terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc07"
    }
  }
}

resource "proxmox_vm_qemu" "vm" {
  target_node = var.target_node
  name        = var.hostname
  vmid        = var.vmid

  # Clone from template or use ISO
  clone = var.clone_template

  # VM settings
  cpu {
    cores   = var.cores
    sockets = var.sockets
    type    = var.kvm_enabled ? "host" : "qemu64"
  }
  memory = var.memory

  # Boot settings
  boot  = "order=scsi0"
  agent = 0 # Disable guest agent to avoid permission issues
  kvm   = var.kvm_enabled

  # Disk configuration
  scsihw = "virtio-scsi-pci"
  disks {
    scsi {
      scsi0 {
        disk {
          size    = var.disk_size
          storage = var.storage
        }
      }
    }
    ide {
      ide2 {
        cloudinit {
          storage = var.storage
        }
      }
    }
  }

  # Network configuration
  network {
    id     = 0
    model  = "virtio"
    bridge = var.bridge
  }

  # Cloud-init settings
  ipconfig0 = var.ip_address != null ? "ip=${var.ip_address}/${var.cidr_suffix},gw=${var.gateway}" : "ip=dhcp"

  ciuser     = "root"
  cipassword = var.password
  sshkeys    = var.ssh_keys

  # Tags
  tags = join(",", concat(["terraform"], var.extra_tags))

  lifecycle {
    prevent_destroy = false
  }
}
