{
  config,
  pkgs,
  inputs,
  ...
}:
{
  users.users.thein3rovert = {
    initialHashedPassword = "$y$j9T$ik3uknc76FacQ8IWNIhqF.$iG95O1UY88EhF9kucdvAuntMZ5ZiYgaK32FXsSdJtv0";
    isNormalUser = true;
    description = "thein3rovert";
    extraGroups = [
      "wheel"
      "networkmanager"
      "libvirtd"
      "flatpak"
      "audio"
      "video"
      "plugdev"
      "input"
      "kvm"
      "qemu-libvirtd"
    ];
    ## For now we dont have ssh configured check video 1 and 2 on how do to this
    #   openssh.authorizedKeys.keys = [
    #     "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC3YEmpYbM+cpmyD10tzNRHEn526Z3LJOzYpWEKdJg8DaYyPbDn9iyVX30Nja2SrW4Wadws0Y8DW+Urs25/wVB6mKl7jgPJVkMi5hfobu3XAz8gwSdjDzRSWJrhjynuaXiTtRYED2INbvjLuxx3X8coNwMw58OuUuw5kNJp5aS2qFmHEYQErQsGT4MNqESe3jvTP27Z5pSneBj45LmGK+RcaSnJe7hG+KRtjuhjI7RdzMeDCX73SfUsal+rHeuEw/mmjYmiIItXhFTDn8ZvVwpBKv7xsJG90DkaX2vaTk0wgJdMnpVIuIRBa4EkmMWOQ3bMLGkLQeK/4FUkNcvQ/4+zcZsg4cY9Q7Fj55DD41hAUdF6SYODtn5qMPsTCnJz44glHt/oseKXMSd556NIw2HOvihbJW7Rwl4OEjGaO/dF4nUw4c9tHWmMn9dLslAVpUuZOb7ykgP0jk79ldT3Dv+2Hj0CdAWT2cJAdFX58KQ9jUPT3tBnObSF1lGMI7t77VU= m3tam3re@m3-nix"
    #  ];
    packages = [ inputs.home-manager.packages.${pkgs.system}.default ];
  };
  users.extraGroups.docker.members = [ "thein3rovert" ];
  home-manager.users.thein3rovert = import ../../../home/thein3rovert/${config.networking.hostName}.nix;
}
