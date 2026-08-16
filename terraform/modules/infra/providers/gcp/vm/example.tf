module "example_vm" {
  source = "../../modules/infra/providers/gcp/vm"

  # Required variables
  project_id    = "my-gcp-project-id"
  zone          = "us-central1-a"
  instance_name = "example-vm-01"

  # Optional: Machine configuration
  machine_type = "e2-medium" # 2 vCPUs, 4 GB memory

  # Optional: Boot disk configuration
  boot_disk_image = "ubuntu-os-cloud/ubuntu-2204-lts"
  boot_disk_size  = 30
  boot_disk_type  = "pd-balanced"

  # Optional: Network configuration
  network           = "default"
  subnetwork        = null
  enable_external_ip = true
  # static_external_ip = "x.x.x.x" # Uncomment to use reserved IP

  # Optional: SSH keys (format: username:ssh-rsa AAAAB3...)
  ssh_keys = "myuser:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC..."

  # Optional: Network tags for firewall rules
  tags = ["http-server", "https-server"]

  # Optional: Resource labels
  labels = {
    environment = "development"
    team        = "infrastructure"
    managed_by  = "terraform"
  }

  # Optional: Custom metadata
  metadata = {
    enable-oslogin = "TRUE"
  }

  # Optional: Startup script
  startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    systemctl enable nginx
    systemctl start nginx
  EOF
}

# Outputs
output "vm_internal_ip" {
  value       = module.example_vm.internal_ip
  description = "Internal IP of the VM"
}

output "vm_external_ip" {
  value       = module.example_vm.external_ip
  description = "External IP of the VM"
}

output "vm_instance_id" {
  value       = module.example_vm.instance_id
  description = "Instance ID"
}
