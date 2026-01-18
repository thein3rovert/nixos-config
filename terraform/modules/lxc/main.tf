terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc07"
    }
  }
}

resource "proxmox_lxc" "ubuntu_container" {
  target_node  = var.target_node
  hostname     = var.hostname
  ostemplate   = var.ostemplate
  password     = var.password
  unprivileged = true
  vmid         = var.container_id
  cores        = var.cores
  memory       = var.memory
  swap         = var.swap
  start        = true
  onboot       = true


  features {
    nesting = true
  }

  rootfs {
    storage = var.storage
    size    = var.disk_size
  }

  network {
    name   = "eth0"
    bridge = var.bridge
    # ip     = var.ip_config
    ip = var.ip_base != null ? "${var.ip_base}.${var.container_id}/${var.cidr_suffix}" : "dhcp"
    gw = var.gateway
  }

  ssh_public_keys = var.ssh_keys


  lifecycle {
    prevent_destroy = false
  }
}
