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
    nesting = true              # Allows running Docker/containers inside the LXC container
    keyctl  = var.enable_keyctl # Enables kernel keyring operations (required by systemd and some security features)
  }

  rootfs {
    storage = var.storage
    size    = var.disk_size
  }

  network {
    name     = "eth0"
    bridge   = var.bridge
    ip       = var.ip_base != null ? "${var.ip_base}.${var.container_id}/${var.cidr_suffix}" : "dhcp"
    gw       = var.gateway
    firewall = var.firewall_enabled
  }

  ssh_public_keys = var.ssh_keys


  lifecycle {
    prevent_destroy = false
  }

  provisioner "local-exec" {
    command = <<-EOT
    sleep 15  # Wait for container to fully initialize
    
    # Base configuration for all containers
    BASE_CONFIG="lxc.cgroup2.devices.allow: c 10:200 rwm\nlxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file"
    
    # Additional K8s configuration if enabled
    ${var.enable_all_devices ? "K8S_CONFIG=\"\\nlxc.cgroup2.devices.allow: a\"" : "K8S_CONFIG=\"\""}
    ${var.disable_seccomp ? "K8S_CONFIG=\"$K8S_CONFIG\\nlxc.seccomp.profile:\"" : ""}
    
    # Apply configuration
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${var.proxmox_host_ip} \
    "echo -e \"$BASE_CONFIG$K8S_CONFIG\" | tee -a /etc/pve/lxc/${self.vmid}.conf && \
     pct stop ${self.vmid} && pct start ${self.vmid}"
  EOT
  }

  tags = join(",", concat(["terraform", var.os_type], var.extra_tags))
}
