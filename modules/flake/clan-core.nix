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
    };

    machines = {
      octavia = {
        nixpkgs.hostPlatform = "x86_64-linux";
        imports = [
          # Host-specific configuration
          ../../hosts/octavia

          # Core system modules (same as regular nixosConfigurations)
          inputs.home-manager.nixosModules.home-manager
          inputs.agenix.nixosModules.default

          # Custom modules
          self.nixosModules.users
          self.nixosModules.nixosOs
          self.nixosModules.hardware
          self.nixosModules.core
          self.nixosModules.containers

          # Overlays
          {
            nixpkgs.overlays = [ self.overlays.default ];
          }

          # Home-Manager configuration
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

          {
            networking.defaultGateway = {
              address = "10.20.0.254";
              interface = "enp1s0";
            };
          }
        ];
      };
    };
  };
}
