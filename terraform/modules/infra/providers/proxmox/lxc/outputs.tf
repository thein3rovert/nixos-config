output "proxmox_host_ip" {
  description = "The IP address of the Proxmox host for the CI provisioner."
  value       = var.proxmox_host_ip
}

output "container_ip" {
  description = "The IP address of the LXC container."
  value       = split("/", proxmox_lxc.container.network[0].ip)[0]
}
