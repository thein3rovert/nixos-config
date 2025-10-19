_: {
  flake = {
    diskoConfigurations = {
      # For now I have just ext4
      lvm-ext4 = ../disko/lvm-ext4/vda;
    };
  };
}
