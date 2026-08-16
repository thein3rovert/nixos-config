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
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
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

# Local values for credentials from Vault
locals {
  root_password = data.vault_kv_secret_v2.proxmox.data["root_password"]
  
  # Format SSH keys for GCP (username:key-content for each user)
  gcp_ssh_keys = join("\n", [
    for user in var.gcp_ssh_key_users : 
    "${user}:${file(var.ssh_public_key_path)}"
  ])
}

# Proxmox provider using Vault secrets
provider "proxmox" {
  pm_api_url          = data.vault_kv_secret_v2.proxmox.data["pm_api_url"]
  pm_api_token_id     = data.vault_kv_secret_v2.proxmox.data["pm_api_token_id"]
  pm_api_token_secret = data.vault_kv_secret_v2.proxmox.data["pm_api_token_secret"]
  pm_tls_insecure     = true
}

# Google Cloud provider (uses GOOGLE_CREDENTIALS from environment)
provider "google" {
  region = var.gcp_region
}

# ====================================
#       LXC | HASHICORP VAULT [BECCA]
# ====================================
module "homelab_vault" {
  source = "../../modules/infra/providers/proxmox/lxc"

  # -- Identity
  hostname = "becca"
  vmid     = 101
  os_type  = "ubuntu"

  # -- Template
  ostemplate = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"

  # -- Resources
  cores     = 1
  memory    = 1024
  disk_size = "2G"
  storage   = var.rootfs_storage

  # -- Network
  ip_base         = var.ip_base
  cidr_suffix     = var.cidr_suffix
  gateway         = var.gateway
  bridge          = var.bridge
  proxmox_host_ip = var.proxmox_host_ip

  # -- Auth
  password = local.root_password
  ssh_keys = file(var.ssh_public_key_path)

  # -- Proxmox
  target_node  = var.target_node
  container_id = 101

  # -- Tags
  extra_tags = ["vault"]
}


# 🖥️ trikru — AI Agent VM
# ━━━━━━━━━━━━━━━━━━━━━━━━
# 📦 Stack: OpenClaw (AI agent gateway) | Ubuntu 22.04 LTS
# ⚙️ Specs: 2 vCPU | 2GB RAM | 20GB Disk
# 🌐 Network: 10.10.10.102/24
# 🏷️ Tags: ai | openclaw | terraform | ubuntu
# 📝 Notes: QEMU Guest Agent enabled | Named after the Trikru clan (The 100)

# module "trikru_vm" {
#   source = "../../modules/infra/providers/proxmox/vm"
#
#   target_node    = var.target_node
#   hostname       = "trikru"
#   vmid           = 102
#   clone_template = "ubuntu-22.04-cloud"
#
#   kvm_enabled   = true # KVM now available after BIOS update
#   agent_enabled = true # QEMU guest agent installed
#   cores         = 2
#   memory        = 4096
#   disk_size     = "20G"
#   storage       = var.rootfs_storage
#
#   bridge      = var.bridge
#   ip_address  = "${var.ip_base}.102"
#   cidr_suffix = var.cidr_suffix
#   gateway     = var.gateway
#
#   password   = local.root_password
#   ssh_keys   = file(var.ssh_public_key_path)
#   extra_tags = ["ai", "openclaw", "ubuntu"]
#
#   description = <<-EOT
#     🖥️ trikru — AI Agent VM
#     ━━━━━━━━━━━━━━━━━━━━━━━━
#     📦 Stack
#        • OpenClaw (AI agent gateway)
#        • Ubuntu 22.04 LTS (Jammy)
#     ⚙️ Specs
#        • 2 vCPU | 2GB RAM | 20GB Disk
#        • Node: thein3rovert
#     🌐 Network
#        • IP: 10.10.10.102/24
#        • Interface: eth0
#     🏷️ Tags: ai | openclaw | terraform | ubuntu
#     📝 Notes
#        • Managed by Terraform
#        • QEMU Guest Agent: enabled
#        • Named after the Trikru clan (The 100)
#   EOT
# }

module "k3s_control_plane_01" {
  source = "../../modules/infra/providers/proxmox/vm"

  target_node    = var.target_node
  hostname       = "Raven"
  vmid           = 111
  clone_template = "ubuntu-22.04-cloud"

  kvm_enabled   = true # KVM now available after BIOS update
  agent_enabled = true # QEMU guest agent installed
  cores         = 2
  memory        = 4096
  disk_size     = "30G"
  storage       = var.rootfs_storage

  bridge      = var.bridge
  ip_address  = "${var.ip_base}.111"
  cidr_suffix = var.cidr_suffix
  gateway     = var.gateway

  password   = local.root_password
  ssh_keys   = file(var.ssh_public_key_path)
  extra_tags = ["k3s", "ubuntu"]

  description = <<-EOT
    k3s Server Control Plane
  EOT
}

module "k3s_control_plane_02" {
  source = "../../modules/infra/providers/proxmox/vm"

  target_node    = var.target_node
  hostname       = "lincoln"
  vmid           = 112
  clone_template = "ubuntu-22.04-cloud"

  kvm_enabled   = true # KVM now available after BIOS update
  agent_enabled = true # QEMU guest agent installed
  cores         = 2
  memory        = 4096
  disk_size     = "30G"
  storage       = var.rootfs_storage

  bridge      = var.bridge
  ip_address  = "${var.ip_base}.112"
  cidr_suffix = var.cidr_suffix
  gateway     = var.gateway

  password   = local.root_password
  ssh_keys   = file(var.ssh_public_key_path)
  extra_tags = ["k3s", "ubuntu"]

  description = <<-EOT
    k3s Server Control Plane
  EOT
}


# ====================================
#       LXC | GITHUB-RUNNER
# ====================================

module "github_runner" {
  source = "../../modules/infra/providers/proxmox/lxc"

  target_node = var.target_node
  password    = local.root_password
  hostname    = "github-runner"
  vmid        = 120
  ostemplate  = var.ostemplate
  cores       = 2
  memory      = 4096
  # Due to 00M Hang during peaK nixos build
  # i am upgarding the swap to 2gb
  swap        = 2048
  disk_size   = "100G"
  storage     = "LVM_MAIN" # Use the 1TB HDD instead of LVM thin pool

  bridge          = var.bridge
  ip_base         = var.ip_base
  cidr_suffix     = var.cidr_suffix
  gateway         = var.gateway
  proxmox_host_ip = var.proxmox_host_ip

  ssh_keys = file(var.ssh_public_key_path)

  container_id = 120
  os_type      = "ubuntu"
  extra_tags   = ["github-runner", "ci"]
}

# ====================================
#  LXC | OBSIDIAN AS KNOWLEDHE BASE
# ====================================

module "agent_knowledge_base" {
  source = "../../modules/infra/providers/proxmox/lxc"

  target_node = var.target_node
  password    = local.root_password
  hostname    = "trikru"
  vmid        = 102
  ostemplate  = var.ostemplate
  cores       = 2
  memory      = 2048
  swap        = 512
  disk_size   = "20G"
  storage     = "LVM_MAIN" # Use the 1TB HDD instead of LVM thin pool

  bridge          = var.bridge
  ip_base         = var.ip_base
  cidr_suffix     = var.cidr_suffix
  gateway         = var.gateway
  proxmox_host_ip = var.proxmox_host_ip

  ssh_keys = file(var.ssh_public_key_path)

  container_id = 102
  os_type      = "ubuntu"
  extra_tags   = ["obsidian", "knowledge-base"]
}

# ====================================
#       GCP | VM INSTANCE
# ====================================

module "gcp_vm" {
  source = "../../modules/infra/providers/gcp/vm"

  # Required
  project_id    = var.gcp_project_id
  zone          = var.gcp_zone
  instance_name = var.gcp_instance_name

  # Machine config
  machine_type = var.gcp_machine_type

  # Disk config
  boot_disk_image = var.gcp_boot_disk_image
  boot_disk_size  = var.gcp_boot_disk_size
  boot_disk_type  = var.gcp_boot_disk_type

  # Network config
  network            = var.gcp_network
  enable_external_ip = var.gcp_enable_external_ip

  # SSH access
  ssh_keys = local.gcp_ssh_keys

  # Tags and labels
  tags   = var.gcp_tags
  labels = var.gcp_labels

  # Optional startup script
  startup_script = var.gcp_startup_script
}

