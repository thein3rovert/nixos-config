output "container_ip" {
  description = "The IP address of the LEMP LXC container."
  value       = split("/", proxmox_lxc.ubuntu_container.network[0].ip)[0]
}

