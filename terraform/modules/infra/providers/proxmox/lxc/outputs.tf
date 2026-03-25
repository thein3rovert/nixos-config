output "proxmox_host_ip" {
  description = "The IP address of the Proxmox host for the CI provisioner."
  value       = var.proxmox_host_ip
}

output "container_ip" {
  description = "The IP address of the LEMP LXC container."
  value       = split("/", proxmox_lxc.ubuntu_container.network[0].ip)[0]
}

