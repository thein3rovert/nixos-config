{
  description = ''
    This is a configiration for managing multiple nixos machines
  '';

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nix-colors.url = "github:misterio77/nix-colors";

    ghostty = {
      url = "github:ghostty-org/ghostty";
    };

    agenix.url = "github:ryantm/agenix";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    #nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # ADDED: Colmena input
    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      home-manager,
      nixpkgs,
      nix-colors,
      ghostty,
      agenix,
      disko,
      colmena,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      allSystems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      # forAllSystems = nixpkgs.lib.genAttrs systems;

      # Defines a function called 'forAllSystems' that takes a function 'f' as an argument
      forAllSystems =
        f:
        # Calls 'genAttrs' from nixpkgs' lib to generate an attribute set for all systems in 'allSystems'
        self.inputs.nixpkgs.lib.genAttrs allSystems (
          system:
          # For each system, call the function 'f' with a set containing 'pkgs'
          f {
            # 'pkgs' is Nixpkgs imported for the current system, with overlays and unfree packages allowed
            pkgs = import self.inputs.nixpkgs {
              inherit system; # Use overlays and current system architecture
              config.allowUnfree = true;
            };
          }
        );
    in
    {
      # packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
      overlays = import ./overlays { inherit inputs; };

      nixosConfigurations = {

        # === MAIN (LOCAL) ===
        nixos = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs nix-colors; };
          modules = [
            ./hosts/nixos
            { environment.systemPackages = [ ghostty.packages.x86_64-linux.default ]; }
            agenix.nixosModules.default
          ];
        };

        # === TEST VM ===
        demo = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs outputs; };
          modules = [
            ./hosts/demo
            inputs.disko.nixosModules.disko
            agenix.nixosModules.default
          ];
        };

        # INFO: === TEST SERVER ===
        # srv-test-1 = nixpkgs.lib.nixosSystem {
        #   system = "x86_64-linux";
        #   specialArgs = {
        #     inherit inputs outputs self;
        #   };
        #   modules = [
        #
        #   ];
        # };

        # === SERVER CONFIGURATIONS ===
        # INFO: HOLD OFF ANY TEST ON SEVER USE SRV-TEST-1
        vps-het-1 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit self inputs outputs; };
          modules = [
            ./hosts/vps-het-1
            self.inputs.home-manager.nixosModules.home-manager
            agenix.nixosModules.default
            inputs.disko.nixosModules.disko
            {
              home-manager = {
                # backupFileExtension = "backup";
                extraSpecialArgs = { inherit self; };
                useGlobalPkgs = true;
                useUserPackages = true;
              };

              nixpkgs = {
                config.allowUnfree = true;
              };
            }
          ];
        };
      };

      # === HOME CONFIGURATION "LOCAL ONLY" ===
      homeConfigurations = {
        "thein3rovert@nixos" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [ ./home/thein3rovert/nixos.nix ];
        };

        # "thein3rovert-cloud" = home-manager.lib.homeManagerConfiguration {
        #   pkgs = nixpkgs.legacyPackages."x86_64-linux";
        #   extraSpecialArgs = { inherit inputs outputs; };
        #   modules = [ ./hosts/vps-het-1/home.nix ];
        # };

      };

      # INFO: Ignore error "unknown flake output 'homeManagerModules'" as
      # it's not in use yet
      homeManagerModules = {
        thein3rovert-cloud = ./home/thein3rovert-cloud;
        # default = ./modules/home # INFO:  Since i dont have default yet, have to remove every "self.homeManagerModules.default"
      };

      # === COLMENA CONFIG "Deployment" ===

      colmena = {
        meta = {
          nixpkgs = import nixpkgs {
            system = "x86_64-linux";
          };
          specialArgs = { inherit self inputs outputs; };
        };

        # === NODE ONE ===
        demo = {
          deployment = {
            targetHost = "demo";
            targetPort = 22;
            targetUser = "thein3rovert";
            buildOnTarget = true;
            tags = [ "homelab" ]; # TODO: Change tag later
          };
          nixpkgs.system = "x86_64-linux";
          imports = [
            ./hosts/demo
            inputs.disko.nixosModules.disko
            # agenix.nixosModules.defaults
          ];
        };

        # === NODE TWO ===
        vps-het-1 = {
          deployment = {
            targetHost = "vps-het-1"; # Use the actual hostname or IP
            targetPort = 22;
            targetUser = "thein3rovert-cloud";
            buildOnTarget = true;
            tags = [
              "vps"
              "production"
            ];
          };
          nixpkgs.system = "x86_64-linux";
          imports = [
            ./hosts/vps-het-1
            agenix.nixosModules.default
            inputs.disko.nixosModules.disko
            self.inputs.home-manager.nixosModules.home-manager
          ];
        };

      };

      #  ADDED: New colmenaHive output
      #  colmenaHive = colmena.lib.makeHive self.outputs.colmena;
    };
}
