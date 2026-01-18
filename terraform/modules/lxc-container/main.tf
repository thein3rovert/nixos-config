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
  ostemplate   = var.template
  password     = var.password
  unprivileged = true

  cores  = var.cores
  memory = var.memory
  swap   = var.swap

  rootfs {
    storage = var.storage
    size    = var.disk_size
  }

  network {
    name   = "eth0"
    bridge = var.bridge
    ip     = var.ip_config
  }

  ssh_public_keys = var.ssh_keys

  start = true

  features = "nesting=1,keyctl=1"
  lxc {
    key   = "lxc.cgroup2.devices.allow"
    value = "c 10:200 rwm"
  }
  lxc {
    key   = "lxc.mount.entry"
    value = "/dev/net/tun dev/net/tun none bind,create=file"
  }

  lifecycle {
    prevent_destroy = true
  }
}
