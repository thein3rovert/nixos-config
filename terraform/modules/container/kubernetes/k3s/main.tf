locals {
  # Merge control plane ip and worker ip into one combine list
  # Example: ["10.0.0.1", "10.0.0.2"] + ["10.0.0.3", "10.0.0.4"] → ["10.0.0.1", "10.0.0.2", "10.0.0.3", "10.0.0.4"]
  control_plane_plus_worker_ips = concat(var.control_plane_ips, var.worker_ips)
}

# Run for both control plane and worker node
resource "terraform_data" "install_prereqs" {
  # For each ip in the combined list, create one instance of this resource
  count = length(local.control_plane_plus_worker_ips)

  input = {
    # IP of specific node (pick the right one)
    ip          = local.control_plane_plus_worker_ips[count.index]
    user        = var.ssh_user
    private_key = sensitive(file("${var.ssh_pub_key_file_path}"))
  }

  provisioner "remote-exec" {
    inline = [
      <<-EOT
        #!/bin/bash

        echo "Detecting package manager..."
        if command -v apt-get >/dev/null 2>&1; then
          echo "APT-based system detected"

          timeout=300
          elapsed=0

          while lsof /var/lib/dpkg/lock-frontend >/dev/null 2>&1 || \
                lsof /var/lib/dpkg/lock >/dev/null 2>&1 || \
                lsof /var/lib/apt/lists/lock >/dev/null 2>&1 || \
                lsof /var/cache/apt/archives/lock >/dev/null 2>&1
          do
            if [ "$elapsed" -ge "$timeout" ]; then
              echo "Timeout waiting for apt lock!"
              exit 1
            fi
            echo "Waiting for apt lock... elapsed:" $elapsed
            sleep 2
            elapsed=$((elapsed + 2))
          done

          echo "Installing packages with apt..."
          sudo apt-get update -y
          sudo apt-get install -y curl gettext

        elif command -v dnf >/dev/null 2>&1; then
          echo "DNF-based system detected"

          timeout=300
          elapsed=0

          while fuser /var/cache/dnf/metadata_lock.pid >/dev/null 2>&1
          do
            if [ "$elapsed" -ge "$timeout" ]; then
              echo "Timeout waiting for dnf lock!"
              exit 1
            fi
            echo "Waiting for dnf lock... elapsed:" $elapsed
            sleep 2
            elapsed=$((elapsed + 2))
          done

          echo "Installing packages with dnf..."
          sudo dnf install -y curl gettext

        else
          echo "No supported package manager found."
          exit 1
        fi
      EOT
    ]

    connection {
      type        = "ssh"
      host        = self.input.ip
      user        = self.input.user
      private_key = self.input.private_key

      bastion_host        = var.bastion_host
      bastion_user        = var.bastion_user
      bastion_port        = var.bastion_port
      bastion_private_key = var.bastion_host != null ? self.input.private_key : null
    }
  }
}


# Install k3s on initial control plane node
resource "ssh_resource" "install_k3s_server" {
  # triggers = {
  #   always_run = "${timestamp()}"
  # }

  # Pick the first ip in the list as control plane
  host        = var.control_plane_ips[0]
  user        = var.ssh_user
  private_key = file("${var.ssh_pub_key_file_path}")

  bastion_host        = var.bastion_host
  bastion_user        = var.bastion_user
  bastion_port        = var.bastion_port
  bastion_private_key = var.bastion_host != null ? file("${var.ssh_pub_key_file_path}") : null

  commands = [
    #  If a Tailscale IP is provided, it adds a second --tls-san for that IP too,
    #  so the cert is also valid when accessed over the Tailscale VPN
    "curl -sfL https://get.k3s.io | sh -s - server --cluster-init --tls-san ${var.kube_api_loadbalancer_dns_name}${var.tailscale_ip != null ? " --tls-san ${var.tailscale_ip}" : ""}"
  ]
  depends_on = [terraform_data.install_prereqs]

  lifecycle {
    ignore_changes = [triggers]
  }
}

# Get k3s server token, used to join other nodes to the cluster
resource "ssh_resource" "get_server_node_token" {
  # triggers = {
  #   always_run = "${timestamp()}"
  # }

  host        = var.control_plane_ips[0]
  user        = var.ssh_user
  private_key = file("${var.ssh_pub_key_file_path}")

  bastion_host        = var.bastion_host
  bastion_user        = var.bastion_user
  bastion_port        = var.bastion_port
  bastion_private_key = var.bastion_host != null ? file("${var.ssh_pub_key_file_path}") : null

  commands = [
    "sudo cat /var/lib/rancher/k3s/server/token"
  ]
  depends_on = [ssh_resource.install_k3s_server]

  lifecycle {
    ignore_changes = [triggers]
  }
}

# Compute other required values
locals {
  raw_server_node_token = sensitive(ssh_resource.get_server_node_token.result)
  server_node_token     = regex(".*::server:.*", local.raw_server_node_token)

  # Takes in a list of control place, take element from index 1 to the end
  # Example: ["10.0.0.1", "10.0.0.2", "10.0.0.3"] and we take ["10.0.0.2", "10.0.0.3"]
  other_control_plane_server_ips = slice(var.control_plane_ips, 1, length(var.control_plane_ips))
}

# Install and join other control plane nodes to the cluster
# Join existing control plane cluster to server (main control plane)
resource "ssh_resource" "install_k3s_control_plane" {
  # triggers = {
  #   always_run = "${timestamp()}"
  # }

  # Create one instance of control plane per IP
  count = length(local.other_control_plane_server_ips)

  # Pick one ip in the list except [0]
  host        = local.other_control_plane_server_ips[count.index]
  user        = var.ssh_user
  private_key = file("${var.ssh_pub_key_file_path}")

  bastion_host        = var.bastion_host
  bastion_user        = var.bastion_user
  bastion_port        = var.bastion_port
  bastion_private_key = var.bastion_host != null ? file("${var.ssh_pub_key_file_path}") : null


  # Points to the first control plane node on the default K3s API port 6443
  commands = [
    "curl -fL https://get.k3s.io | sh -s - server --token ${local.server_node_token} --cluster-init --server https://${var.control_plane_ips[0]}:6443 --tls-san ${var.kube_api_loadbalancer_dns_name}"
  ]
  depends_on = [ssh_resource.install_k3s_server]
}
