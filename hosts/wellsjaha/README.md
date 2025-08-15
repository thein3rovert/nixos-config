## WellsJaha

---

## Overview

This server runs as a virtual machine and serves as a test environment for development and experimentation. The configuration is optimized for simplicity and flexibility using LVM for disk management.

---

## Specs

| Component | Details         |
| --------- | --------------- |
| **Type**  | Virtual Machine |
| **Disk**  | 1x Virtual Disk |

---

## 🗂 Filesystems

### `/` (Root)

- **Format**: ext4
- **Provisioning**: Logical Volume (LVM)
- **Mount Options**: defaults

### `/boot`

- **Format**: vfat (FAT32)
- **Purpose**: EFI System Partition for booting (supports UEFI)
- **Mountpoint**: `/boot`
