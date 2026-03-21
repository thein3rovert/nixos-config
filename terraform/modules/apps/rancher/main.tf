# Install cert-manager
resource "ssh_resource" "install_cert_manager" {
  triggers = {
    always_run = "${timestamp()}"
  }

  host         = var.control_plane_ips[0]
  user         = var.ssh_user
  private_key  = file("${var.ssh_private_key_path}")

  bastion_host        = var.bastion_host
  bastion_user        = var.bastion_user
  bastion_port        = var.bastion_port
  bastion_private_key = var.bastion_host != null ? file("${var.ssh_private_key_path}") : null

  file {
    source      = "${path.module}/manifests/cert-manager.yaml"
    destination = "/tmp/cert-manager.yaml"
    permissions = "0644"
  }

  commands = [
    "sudo mv /tmp/cert-manager.yaml /var/lib/rancher/k3s/server/manifests/cert-manager.yaml",
    "sleep 30"
  ]
}

# Install Rancher (depends on cert-manager)
resource "ssh_resource" "install_rancher" {
  triggers = {
    always_run = "${timestamp()}"
  }

  host         = var.control_plane_ips[0]
  user         = var.ssh_user
  private_key  = file("${var.ssh_private_key_path}")

  bastion_host        = var.bastion_host
  bastion_user        = var.bastion_user
  bastion_port        = var.bastion_port
  bastion_private_key = var.bastion_host != null ? file("${var.ssh_private_key_path}") : null

  file {
    source      = "${path.module}/manifests/rancher.yaml"
    destination = "/tmp/rancher.yaml"
    permissions = "0644"
  }

  commands = [
    "sudo mv /tmp/rancher.yaml /var/lib/rancher/k3s/server/manifests/rancher.yaml",
    "echo 'Rancher installation initiated. Check status with: kubectl get pods -n cattle-system'"
  ]

  depends_on = [ssh_resource.install_cert_manager]
}

# Install Rancher IngressRoute for Traefik (accepts any hostname/IP)
resource "ssh_resource" "install_rancher_ingress" {
  triggers = {
    always_run = "${timestamp()}"
  }

  host         = var.control_plane_ips[0]
  user         = var.ssh_user
  private_key  = file("${var.ssh_private_key_path}")

  bastion_host        = var.bastion_host
  bastion_user        = var.bastion_user
  bastion_port        = var.bastion_port
  bastion_private_key = var.bastion_host != null ? file("${var.ssh_private_key_path}") : null

  file {
    source      = "${path.module}/manifests/rancher-ingress.yaml"
    destination = "/tmp/rancher-ingress.yaml"
    permissions = "0644"
  }

  commands = [
    "sudo mv /tmp/rancher-ingress.yaml /var/lib/rancher/k3s/server/manifests/rancher-ingress.yaml",
    "echo 'Rancher ingress deployed'"
  ]

  depends_on = [ssh_resource.install_rancher]
}
