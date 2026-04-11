terraform {
  required_providers {
    incus = {
      source  = "lxc/incus"
      version = "~> 0.1"
    }
  }
}

resource "incus_instance" "ubuntu_vm" {
  remote   = "marcus"
  name     = var.vm_name
  image    = var.image
  type     = "virtual-machine"
  profiles = ["default"]
  running  = false

  device {
    name = "root"
    type = "disk"
    properties = {
      pool = "default"
      path = "/"
      size = var.disk_size
    }
  }

  config = {
    "limits.cpu"    = var.cpu_cores
    "limits.memory" = "${var.memory_mb}MiB"
    "cloud-init.user-data" = templatefile("${path.module}/cloud-init.yaml", {
      hostname    = var.vm_name
      ssh_keys    = var.ssh_keys
    })
    "cloud-init.network-config" = var.static_ip != null ? templatefile("${path.module}/network-config.yaml", {
      static_ip   = var.static_ip
      gateway     = var.gateway
      dns_servers = var.dns_servers
    }) : ""
  }
}

output "vm_name" {
  value = incus_instance.ubuntu_vm.name
}

output "vm_status" {
  value = incus_instance.ubuntu_vm.status
}

output "vm_ipv4_address" {
  value = incus_instance.ubuntu_vm.ipv4_address
}
