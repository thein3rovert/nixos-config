{ lib, ... }:
{
  disko.devices = {
    # Define a physical disk named disk1, typically the main storage device
    disk.disk1 = {
      # Set the default device path for the disk (sda or vda)
      device = lib.mkDefault "/dev/vda";
      type = "disk";

      # Partition layout using GPT (GUID Partition Table)
      content = {
        type = "gpt";
        partitions = {
          # BIOS boot partition (required for legacy boot on GPT)
          boot = {
            name = "boot";
            size = "1M";
            type = "EF02"; # BIOS boot partition type
          };

          # EFI System Partition (for UEFI boot)
          esp = {
            name = "ESP";
            size = "500M";
            type = "EF00"; # UEFI system partition type
            content = {
              type = "filesystem";
              format = "vfat"; # FAT32 filesystem for EFI compatibility
              mountpoint = "/boot"; # Mount this partition at /boot
            };
          };

          # Root partition, used as a physical volume for LVM
          root = {
            name = "root";
            size = "100%"; # Use all remaining space
            content = {
              type = "lvm_pv"; # Mark as LVM physical volume
              vg = "pool"; # Add to the volume group named "pool"
            };
          };
        };
      };
    };

    # Define a logical volume group named "pool"
    # INFO: LVM provides flexible disk management,
    # allowing easy resizing, snapshots, and dynamic
    # allocation without repartitioning.
    lvm_vg = {
      pool = {
        type = "lvm_vg";

        # Define logical volumes within the volume group
        lvs = {
          root = {
            size = "100%FREE"; # Use all available space in the volume group
            content = {
              type = "filesystem";
              format = "ext4"; # Format the volume with ext4 filesystem
              mountpoint = "/"; # Mount as the root filesystem
              mountOptions = [
                "defaults" # Standard mount options
              ];
            };
          };
        };
      };
    };
  };
}
