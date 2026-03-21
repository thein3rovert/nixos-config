
output "incus_vm_ip" {
  description = "IP address of the Incus VM (DHCP until static IP applies)"
  value       = module.incus_ubuntu_vm.vm_ipv4_address
}

output "incus_vm_static_ip" {
  description = "Configured static IP for the Incus VM"
  value       = "10.10.20.100"
}

output "k3s_install_result" {
  description = "K3s installation result"
  value       = module.k3s_incus.k3s_server_install_result
}

output "k3s_server_token" {
  description = "K3s server token for joining nodes"
  value       = module.k3s_incus.k3s_server_token
  sensitive   = true
}

output "kubeconfig_location" {
  description = "Location of kubeconfig on the server"
  value       = "ssh ${var.ssh_user}@10.10.20.100 'sudo cat /etc/rancher/k3s/k3s.yaml'"
}

output "kube_api_endpoint" {
  description = "Kubernetes API endpoint"
  value       = module.k3s_incus.kube_api_endpoint
}

# output "rancher_url" {
#   description = "Rancher UI URL"
#   value       = module.rancher.rancher_url
# }

# output "rancher_instructions" {
#   description = "Instructions for accessing Rancher"
#   value       = module.rancher.rancher_instructions
# }
