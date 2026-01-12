resource "proxmox_vm_qemu" "ubuntu_vm" {
  name        = var.vm_name
  target_node = var.target_node
  clone       = var.template_name
  
  cores   = var.cores
  memory  = var.memory
  
  disk {
    size    = var.disk_size
    type    = "scsi"
    storage = var.storage
  }
  
  network {
    model  = "virtio"
    bridge = var.bridge
  }
  
  os_type   = "cloud-init"
  ipconfig0 = var.ip_config
  ciuser    = var.ci_user
  sshkeys   = var.ssh_keys
}
