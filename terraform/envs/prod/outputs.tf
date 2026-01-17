# outputs.tf - Define the output values
output "container_root_password" {
  description = "The root password set for the new LXC container."
  value       = var.root_password
  sensitive   = true
}
