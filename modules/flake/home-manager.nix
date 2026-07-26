{ self, ... }:
{
  flake = {
    homeManagerModules = {
      thein3rovert = ../../homes/thein3rovert;
      default = ../home;
    };

    # INFO: Standalone home-manager configurations for non-NixOS systems
    # Use with: home-manager switch --flake .#thein3rovert@trikru
    homeConfigurations =
      let
        mkStandalone =
          {
            host,
            system ? "x86_64-linux",
            extraModules ? [ ],
          }:
          self.inputs.home-manager.lib.homeManagerConfiguration {
            pkgs = import self.inputs.nixpkgs {
              inherit system;
              config.allowUnfree = true;
              overlays = [ self.overlays.default ];
            };

            extraSpecialArgs = {
              inherit self;
              inputs = self.inputs;
            };

            modules = [
              ../../homes/thein3rovert/${host}.nix
            ] ++ extraModules;
          };
      in
      {
        # Ubuntu 22.04 server (Proxmox VM) — hostname: trikru
        "thein3rovert@trikru" = mkStandalone { host = "trikru"; };
      };
  };
}