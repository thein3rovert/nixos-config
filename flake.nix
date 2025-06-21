{
  description = ''
    For questions just DM me on X: https://twitter.com/@m3tam3re
    There is also some NIXOS content on my YT channel: https://www.youtube.com/@m3tam3re

    One of the best ways to learn NIXOS is to read other peoples configurations. I have personally learned a lot from Gabriel Fontes configs:
    https://github.com/Misterio77/nix-starter-configs
    https://github.com/Misterio77/nix-config

    Please also check out the starter configs mentioned above.
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
      # colmena,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      systems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
      overlays = import ./overlays { inherit inputs; };

      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs nix-colors; };
          modules = [
            ./hosts/nixos
            { environment.systemPackages = [ ghostty.packages.x86_64-linux.default ]; }
            agenix.nixosModules.default
          ];
        };
        demo = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs outputs; };
          modules = [
            ./hosts/demo
            inputs.disko.nixosModules.disko
            agenix.nixosModules.default
          ];
        };

        # === SERVER CONFIGURATIONS ===

        vps-het-1 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs outputs; };
          modules = [
            ./hosts/vps-het-1
            agenix.nixosModules.default
          ];
        };
      };

      homeConfigurations = {
        "thein3rovert@nixos" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [ ./home/thein3rovert/nixos.nix ];
        };
        "thein3rovert-cloud@vps-het-1" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [ ./home/thein3rovert/vps-het-1.nix ];
        };

      };

      colmena = {
        meta = {
          nixpkgs = import nixpkgs {
            system = "x86_64-linux";
          };
          specialArgs = { inherit inputs outputs; };
        };

        # Deployment Nodes
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
      };
      # # ADDED: New colmenaHive output
      #  colmenaHive = colmena.lib.makeHive self.outputs.colmena;
    };
}
