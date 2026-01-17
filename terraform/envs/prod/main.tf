terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc07" # Using the required version
    }
  }
}

provider "proxmox" {
  pm_api_url          = "https://10.10.10.8:8006/api2/json"
  pm_tls_insecure     = true
  pm_api_token_id     = "terraform-prov@pve!terraform"
  pm_api_token_secret = "0f955002-e7ec-4290-b930-22dd85e536ba"
}

# module "ubuntu_container" {
#   source = "../../modules/lxc"
#
#   target_node = "thein3rovert"
#   hostname    = "ubuntu-ct-02"
#   template    = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
#   cores       = 2
#   memory      = 2048
#   disk_size   = "8G"
#   storage     = "local-lvm"
#   ssh_keys    = file("/home/thein3rovert/.ssh/id_ed25519.pub")
# }


