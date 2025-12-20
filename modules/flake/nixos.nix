{
  self,
  inputs,
  nix-colors,
  colmena,
  nixpkgs-unstable-small,
  ...
}:
{
  flake = {

    # ================================
    #        NIXOS MODULES
    # ================================
    nixosModules = {
      # INFO: Contain Reusable Variables, Types and more ...
      base = ./modules/base;
      containers = ./modules/nixos/containers;
      core = ./modules/core;
      hardware = ./modules/hardware;
      locale-en-uk = ./modules/nixos/locale/en-uk;
      nixosOs = ./modules/nixos/os;
      snippets = ./modules/snippets;
      users = ./modules/nixos/users;
    };

    nixosConfigurations =
      let
        modules = self.nixosModules;
      in
      inputs.nixpkgs.lib.genAttrs
        [
          "bellamy"
          "demo"
          "nixos"
          "vps-het-1"
          "wellsjaha"

          # Managed by incus
          # "lexa" (LXC)

          # Managed by clan
          # "octavia"

          # Managed by Proxmox
          # finn  (Lxc - Killed by grounders)
        ]
        (
          host:
          inputs.nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit
                self
                nix-colors
                colmena
                nixpkgs-unstable-small
                ;
            };

            modules = [
              # Host-specific configuration
              ../../hosts/${host}

              # Core system modules
              inputs.agenix.nixosModules.default
              inputs.disko.nixosModules.disko
              inputs.home-manager.nixosModules.home-manager

              # Custom modules
              modules.base
              modules.containers
              modules.core
              modules.hardware
              modules.nixosOs
              modules.snippets
              modules.users

              # Overlays
              {
                nixpkgs.overlays = [ self.overlays.default ];
              }

              # Additional packages
              {
                environment.systemPackages = [
                  # ghostty.packages.x86_64-linux.default
                  inputs.agenix.packages.x86_64-linux.default
                ];
              }

              # ---- Home-Manager Config ----
              {
                home-manager = {
                  backupFileExtension = "backup";
                  extraSpecialArgs = { inherit self; };
                  useGlobalPkgs = true;
                  useUserPackages = true;
                };
                nixpkgs = {
                  config.allowUnfree = true;
                };
              }
            ];
          }
        );
  };
}
