{ inputs, self, ... }:
{
  # Import clan-core flake module
  imports = [
    inputs.clan-core.flakeModules.default
  ];

  # ==============================
  #     Clan Configuration
  # ==============================
  clan = {
    meta.name = "octavia-clan-test";

    specialArgs = {
      inherit
        self
        inputs
        ;
      inherit (inputs)
        nix-colors
        colmena
        nixpkgs-unstable-small
        ;
    };

    machines = {
      octavia = {
        nixpkgs.hostPlatform = "x86_64-linux";
        imports = [
          ../../hosts/octavia
          inputs.home-manager.nixosModules.home-manager
          inputs.agenix.nixosModules.default
          self.nixosModules.users
          self.nixosModules.nixosOs
          self.nixosModules.hardware
          self.nixosModules.core
          self.nixosModules.containers
          {
            nixpkgs.overlays = [ self.overlays.default ];
          }
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
          # Clan networking configuration
          {
            clan.core.networking.targetHost = "10.20.0.2";
          }
        ];
      };
    };
  };
}
