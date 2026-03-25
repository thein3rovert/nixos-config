output "vm_id" {
  value = proxmox_vm_qemu.vm.vmid
}

output "vm_name" {
  value = proxmox_vm_qemu.vm.name
}

output "vm_ip" {
  value = proxmox_vm_qemu.vm.default_ipv4_address
}
