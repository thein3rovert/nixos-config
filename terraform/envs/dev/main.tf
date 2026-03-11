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


