output "cert_manager_install_result" {
  description = "Result of cert-manager installation"
  value       = ssh_resource.install_cert_manager.result
}

output "rancher_install_result" {
  description = "Result of Rancher installation"
  value       = ssh_resource.install_rancher.result
}

output "rancher_url" {
  description = "URL to access Rancher UI"
  value       = "https://${var.rancher_hostname}"
}

output "rancher_bootstrap_password" {
  description = "Bootstrap password for Rancher admin user"
  value       = var.rancher_bootstrap_password
  sensitive   = true
}

output "rancher_instructions" {
  description = "Instructions for accessing Rancher"
  value       = <<-EOT
    Rancher has been installed on your k3s cluster.

    To access Rancher:
    1. Check deployment status: kubectl get pods -n cattle-system
    2. Wait for all pods to be Running
    3. Access via: https://${var.rancher_hostname}
    4. Login with username 'admin' and the bootstrap password

    To import your Proxmox k8s cluster:
    1. Login to Rancher UI
    2. Click on "Import Existing" cluster
    3. Follow the instructions to run the import command on your Proxmox cluster
  EOT
}
