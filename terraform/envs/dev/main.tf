terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.0"
    }
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc07"
    }
    incus = {
      source  = "lxc/incus"
      version = "~> 0.1"
    }
  }
}

# Vault provider configuration
provider "vault" {
  address = var.vault_address
  token   = var.vault_token
}

# Retrieve Proxmox credentials from Vault
data "vault_kv_secret_v2" "proxmox" {
  mount = "secret"
  name  = "proxmox"
}

# Proxmox provider using Vault secrets
provider "proxmox" {
  pm_api_url          = data.vault_kv_secret_v2.proxmox.data["pm_api_url"]
  pm_api_token_id     = data.vault_kv_secret_v2.proxmox.data["pm_api_token_id"]
  pm_api_token_secret = data.vault_kv_secret_v2.proxmox.data["pm_api_token_secret"]
  pm_tls_insecure     = true
}

# Incus provider configuration
provider "incus" {
  generate_client_certificates = false
  accept_remote_certificate    = true

  remote {
    name    = "marcus"
    scheme  = "https"
    address = "100.94.20.21"
    port    = "8443"
  }
}


module "ubuntu_container" {
  source = "../../modules/lxc"

  target_node = var.target_node
  password    = var.root_password
  hostname    = "monty"
  vmid        = var.container_id
  ostemplate  = var.ostemplate
  cores       = 2
  memory      = 2048
  swap        = 512
  disk_size   = "8G"
  storage     = var.rootfs_storage
  ssh_keys    = file(var.ssh_public_key_path)

  # Override of default
  gateway         = var.gateway
  cidr_suffix     = var.cidr_suffix
  ip_base         = var.ip_base
  bridge          = var.bridge
  container_id    = 104
  proxmox_host_ip = var.proxmox_host_ip
  extra_tags      = var.extra_tags

}


# ====================================
#       LXC | KUBERNETES | PROXMOX
#
# ===JUMPBOX | KUBERNETES===

# Kubernetes the Hard Way - Jumpbox (Debian 12)
module "k8s_jumpbox" {
  source = "../../modules/lxc"

  target_node = var.target_node
  password    = var.root_password
  hostname    = "jumpbox"
  vmid        = 110
  ostemplate  = "local:vztmpl/debian-12-standard_12.12-1_amd64.tar.zst"
  cores       = 1
  memory      = 512
  swap        = 256
  disk_size   = "10G"
  storage     = var.rootfs_storage
  ssh_keys    = file(var.ssh_public_key_path)

  gateway         = var.gateway
  cidr_suffix     = var.cidr_suffix
  ip_base         = var.ip_base
  bridge          = var.bridge
  container_id    = 110
  proxmox_host_ip = var.proxmox_host_ip
  os_type         = "debian"
  extra_tags      = ["k8s-hardway"]
}


# ====================================
#       LXC | KUBERNETES | PROXMOX
#
# ===SERVER | KUBERNETES | CONTROL PLANE===


# Kubernetes the Hard Way - Server (Debian 12)
module "k8s_server" {
  source = "../../modules/lxc"

  target_node = var.target_node
  password    = var.root_password
  hostname    = "server"
  vmid        = 111
  ostemplate  = "local:vztmpl/debian-12-standard_12.12-1_amd64.tar.zst"
  cores       = 1
  memory      = 2048
  swap        = 512
  disk_size   = "20G"
  storage     = var.rootfs_storage
  ssh_keys    = file(var.ssh_public_key_path)

  gateway         = var.gateway
  cidr_suffix     = var.cidr_suffix
  ip_base         = var.ip_base
  bridge          = var.bridge
  container_id    = 111
  proxmox_host_ip = var.proxmox_host_ip
  os_type         = "debian"
  extra_tags      = ["k8s-hardway"]
}


# ====================================
#       LXC | KUBERNETES | PROXMOX
#
# ===NODE 0 | KUBERNETES | WORKER===


# Kubernetes the Hard Way - Node 0 (Debian 12)
module "k8s_node_0" {
  source = "../../modules/lxc"

  target_node = var.target_node
  password    = var.root_password
  hostname    = "node-0"
  vmid        = 112
  ostemplate  = "local:vztmpl/debian-12-standard_12.12-1_amd64.tar.zst"
  cores       = 1
  memory      = 2048
  swap        = 512
  disk_size   = "20G"
  storage     = var.rootfs_storage
  ssh_keys    = file(var.ssh_public_key_path)

  gateway         = var.gateway
  cidr_suffix     = var.cidr_suffix
  ip_base         = var.ip_base
  bridge          = var.bridge
  container_id    = 112
  proxmox_host_ip = var.proxmox_host_ip
  os_type         = "debian"
  extra_tags      = ["k8s-hardway"]

  # K8s-specific features to match manual Proxmox configuration
  enable_keyctl      = true
  enable_all_devices = true
  disable_seccomp    = true
  firewall_enabled   = false
}


# ====================================
#       LXC | KUBERNETES | PROXMOX
#
# ===NODE 1 | KUBERNETES | WORKER===


# Kubernetes the Hard Way - Node 1 (Debian 12)
module "k8s_node_1" {
  source = "../../modules/lxc"

  target_node = var.target_node
  password    = var.root_password
  hostname    = "node-1"
  vmid        = 113
  ostemplate  = "local:vztmpl/debian-12-standard_12.12-1_amd64.tar.zst"
  cores       = 1
  memory      = 2048
  swap        = 512
  disk_size   = "20G"
  storage     = var.rootfs_storage
  ssh_keys    = file(var.ssh_public_key_path)

  gateway         = var.gateway
  cidr_suffix     = var.cidr_suffix
  ip_base         = var.ip_base
  bridge          = var.bridge
  container_id    = 113
  proxmox_host_ip = var.proxmox_host_ip
  os_type         = "debian"
  extra_tags      = ["k8s-hardway"]

  # K8s-specific features to match manual Proxmox configuration
  enable_keyctl      = true
  enable_all_devices = true
  disable_seccomp    = true
  firewall_enabled   = false
}

# ====================================
#       LXC | GITHUB-RUNNERS
# ====================================

module "github_runner" {
  source = "../../modules/lxc"

  target_node = var.target_node
  password    = var.root_password
  hostname    = "github-runner"
  vmid        = 120
  ostemplate  = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  cores       = 2
  memory      = 4096
  swap        = 1024
  disk_size   = "80G"
  storage     = var.rootfs_storage
  ssh_keys    = file(var.ssh_public_key_path)

  gateway         = var.gateway
  cidr_suffix     = var.cidr_suffix
  ip_base         = var.ip_base
  bridge          = var.bridge
  container_id    = 120
  proxmox_host_ip = var.proxmox_host_ip
  os_type         = "ubuntu"
  extra_tags      = ["github-runner", "ci"]
}

# ====================================
#       VM | KUBERNETES | INCUS
# ====================================

# Ubuntu VM on Incus (marcus server)
module "incus_ubuntu_vm" {
  source = "../../modules/incus-vm"

  vm_name   = "k3s-server"
  image     = "images:ubuntu/24.04/cloud"
  cpu_cores = 4
  memory_mb = 4096
  disk_size = "20GB"
  ssh_keys  = [file(var.ssh_public_key_path)]

  # Static IP configuration for k3s
  static_ip   = "10.10.20.100"
  gateway     = "10.10.20.1"
  dns_servers = ["8.8.8.8", "8.8.4.4"]
}

# ====================================
#       LOCALS | DYNAMIC IP OUTPUTS
# ====================================

locals {
  # Use static IP for k3s (since we configured it in cloud-init)
  control_plane_ips = ["10.10.20.100"]
  worker_ips        = []
  kube_api_loadbalancer_dns_name = var.kube_api_loadbalancer_dns_name
  kube_vip_address  = "10.10.20.100"

  # K3s always needs bastion since it connects to internal IP
  # Rancher can use Tailscale IP directly if available
  rancher_access_ip = var.tailscale_ip != null ? var.tailscale_ip : "10.10.20.100"
  use_bastion_for_rancher = var.tailscale_ip == null
}

# ====================================
#       K3S | KUBERNETES | INCUS
# ====================================

# Wait for cloud-init to complete before installing k3s
resource "time_sleep" "wait_for_cloud_init" {
  depends_on = [module.incus_ubuntu_vm]

  create_duration = "60s"
}

# Install k3s on the Incus Ubuntu VM
module "k3s_incus" {
  source = "../../modules/container/kubernetes/k3s"

  control_plane_ips = local.control_plane_ips
  worker_ips        = local.worker_ips
  ssh_user          = var.ssh_user
  ssh_pub_key_file_path = var.ssh_private_key_path
  kube_api_loadbalancer_dns_name = local.kube_api_loadbalancer_dns_name
  kube_vip_address  = local.kube_vip_address
  kube_vip_enable   = var.kube_vip_enable
  tailscale_ip      = var.tailscale_ip

  # Bastion host configuration to reach VM on internal network (always needed for k3s)
  bastion_host = "100.94.20.21"
  bastion_user = "root"
  bastion_port = 22

  depends_on = [time_sleep.wait_for_cloud_init]
}

# ====================================
#       RANCHER | KUBERNETES MGMT
# ====================================

# Install Rancher for managing k8s clusters
# NOTE: Rancher commented out - too resource intensive for dev setup
# Use k9s or kubectl for cluster management instead
# module "rancher" {
#   source = "../../modules/apps/rancher"
#
#   control_plane_ips     = [local.rancher_access_ip]
#   ssh_user              = var.ssh_user
#   ssh_private_key_path  = var.ssh_private_key_path
#
#   rancher_hostname            = "rancher.local"
#   rancher_bootstrap_password  = "admin"
#
#   # Bastion host configuration (only if Tailscale not available for Rancher)
#   bastion_host = local.use_bastion_for_rancher ? "100.94.20.21" : null
#   bastion_user = "root"
#   bastion_port = 22
#
#   depends_on = [module.k3s_incus]
# }
