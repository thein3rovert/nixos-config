# outputs.tf - Define the output values
output "container_root_password" {
  description = "The root password set for the new LXC container."
  value       = local.root_password
  sensitive   = true
}

# GCP VM Outputs
output "gcp_vm_instance_id" {
  description = "GCP VM instance ID"
  value       = module.gcp_vm.instance_id
}

output "gcp_vm_internal_ip" {
  description = "GCP VM internal IP address"
  value       = module.gcp_vm.internal_ip
}

output "gcp_vm_external_ip" {
  description = "GCP VM external IP address"
  value       = module.gcp_vm.external_ip
}

output "gcp_vm_name" {
  description = "GCP VM instance name"
  value       = module.gcp_vm.instance_name
}

# Secret Manager Outputs
output "tailscale_secret_name" {
  description = "Tailscale secret resource name"
  value       = module.tailscale_secret.secret_name
}

