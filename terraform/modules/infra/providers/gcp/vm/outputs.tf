output "instance_id" {
  value       = google_compute_instance.vm.instance_id
  description = "The server-assigned unique identifier of the instance"
}

output "instance_name" {
  value       = google_compute_instance.vm.name
  description = "The name of the instance"
}

output "internal_ip" {
  value       = google_compute_instance.vm.network_interface[0].network_ip
  description = "Internal IP address of the instance"
}

output "external_ip" {
  value       = length(google_compute_instance.vm.network_interface[0].access_config) > 0 ? google_compute_instance.vm.network_interface[0].access_config[0].nat_ip : null
  description = "External IP address of the instance (null if not assigned)"
}

output "self_link" {
  value       = google_compute_instance.vm.self_link
  description = "The URI of the created resource"
}
