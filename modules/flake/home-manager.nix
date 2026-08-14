# ============================================================================
# HOME-MANAGER FLAKE MODULE
# ============================================================================
# Defines two things:
#   1. homeManagerModules   — reusable modules for BOTH NixOS integration
#                              and standalone home-manager
#   2. homeConfigurations   — standalone configs for non-NixOS hosts
#
# 📖 See docs: `doc-001 - Home-Manager-Configuration-Architecture.md`
# ============================================================================
{ self, ... }:
{
  flake = {
    # ---------------------------------------------------------------------
    # Reusable home-manager modules (referenced by NixOS AND standalone)
    # ---------------------------------------------------------------------
    homeManagerModules = {
      # User base config — resolves to homes/thein3rovert/default.nix
      # Used in NixOS via:  home-manager.users.thein3rovert = self.homeManagerModules.thein3rovert;
      # Used standalone via: modules = [ self.homeManagerModules.thein3rovert ... ]
      thein3rovert = ../../homes/thein3rovert;

      # Custom modules that provide `homeSetup.*` options
      # Imported from homes/thein3rovert/default.nix
      default = ../home;
    };

    # ---------------------------------------------------------------------
    # Standalone home-manager configurations (non-NixOS hosts)
    # ---------------------------------------------------------------------
    # Activate with: home-manager switch --flake .#thein3rovert@<host>
    # NOTE: Standalone mode = home-manager NOT integrated into a NixOS system.
    #       In this mode there is NO `home-manager.users.<name>` wrapper —
    #       user config lives directly at the module root.
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

            # Modules are merged in order — later modules override earlier ones.
            modules = [
              self.homeManagerModules.thein3rovert  # Base config (homes/thein3rovert/default.nix)
              ../../homes/thein3rovert/${host}.nix  # Host-specific overrides
            ]
            ++ extraModules;
          };
      in
      {
        # Ubuntu 22.04 server (Proxmox VM) — hostname: trikru
        "thein3rovert@trikru" = mkStandalone { host = "trikru"; };
      };
  };
}
