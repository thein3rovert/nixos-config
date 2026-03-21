# Outputs for k3s module

output "k3s_server_install_result" {
  description = "Result of k3s server installation"
  value       = ssh_resource.install_k3s_server.result
}

output "k3s_control_plane_install_results" {
  description = "Results of additional control plane installations"
  value       = [for operation in ssh_resource.install_k3s_control_plane : operation.result]
}

output "k3s_server_token" {
  description = "K3s server token for joining nodes"
  value       = ssh_resource.get_server_node_token.result
  sensitive   = true
}

output "control_plane_ips" {
  description = "Control plane node IPs"
  value       = var.control_plane_ips
}

output "worker_ips" {
  description = "Worker node IPs"
  value       = var.worker_ips
}

output "kubeconfig_location" {
  description = "Location of kubeconfig on control plane nodes"
  value       = "/etc/rancher/k3s/k3s.yaml"
}

output "kube_api_endpoint" {
  description = "Kubernetes API endpoint"
  value       = "https://${var.control_plane_ips[0]}:6443"
}
