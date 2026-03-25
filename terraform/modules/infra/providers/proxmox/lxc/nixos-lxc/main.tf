terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc07"
    }
  }
}

resource "proxmox_lxc" "nixos_container" {
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
    nesting = true # Allows running Docker/containers inside the LXC container
    # INFO: only root@pam is allow to set this
    # keyctl  = true # Enables kernel keyring operations (required by systemd and some security features)
  }

  # Block not provided
  # lxc {
  #   key   = "lxc.cgroup2.devices.allow"
  #   value = "c 10:200 rwm"
  # }
  # lxc {
  #   key   = "lxc.mount.entry"
  #   value = "/dev/net/tun dev/net/tun none bind,create=file"
  # }

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

  provisioner "local-exec" {
    command = <<-EOT
    sleep 15  # Wait for container to fully initialize
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${var.proxmox_host_ip} \
    'echo -e "lxc.cgroup2.devices.allow: c 10:200 rwm\nlxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file" | tee -a /etc/pve/lxc/${self.vmid}.conf && \
     pct stop ${self.vmid} && pct start ${self.vmid}'
  EOT
  }

  tags = join(",", concat(["terraform", "nixos"], var.extra_tags))
}
