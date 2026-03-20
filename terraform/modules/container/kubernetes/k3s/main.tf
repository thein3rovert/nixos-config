locals {
  control_plane_plus_worker_ips = concat(var.control_plane_ips, var.worker_ips)
}

resource "terraform_data" "install_prereqs" {
  count = length(local.control_plane_plus_worker_ips)

  input = {
    ip = local.control_plane_plus_worker_ips[count.index]
    user = var.ssh_user
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
    }
  }
}


# Install k3s on initial control plane node
resource "ssh_resource" "install_k3s_server" {
  triggers = {
    always_run = "${timestamp()}"
  }

  host         = var.control_plane_ips[0]
  user         = var.ssh_user
  private_key  = file("${var.ssh_pub_key_file_path}")

  commands = [
     "curl -sfL https://get.k3s.io | sh -s - server --cluster-init --tls-san ${var.kube_api_loadbalancer_dns_name}"
  ]
  depends_on = [ terraform_data.install_prereqs ]
}

# Get k3s server token, used to join other nodes to the cluster
resource "ssh_resource" "get_server_node_token" {
  triggers = {
    always_run = "${timestamp()}"
  }

  host         = var.control_plane_ips[0]
  user         = var.ssh_user
  private_key  = file("${var.ssh_pub_key_file_path}")

  commands = [
     "sudo cat /var/lib/rancher/k3s/server/token"
  ]
  depends_on = [ ssh_resource.install_k3s_server ]
}

# Compute other required values
locals {
  raw_server_node_token = sensitive(ssh_resource.get_server_node_token.result)
  server_node_token = regex(".*::server:.*", local.raw_server_node_token)
  other_control_plane_server_ips = slice(var.control_plane_ips, 1, length(var.control_plane_ips))
}
