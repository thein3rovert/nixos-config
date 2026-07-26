# INFO: deploy-rs configuration for non-NixOS hosts (e.g. Ubuntu servers)
# managed via standalone home-manager.
#
# Usage (build on this workstation, push closure + activate on target):
#   nix run github:serokell/deploy-rs -- --skip-checks .#trikru.home
#   nix run github:serokell/deploy-rs -- --skip-checks .#trikru      # all profiles on node
#   nix run github:serokell/deploy-rs -- --skip-checks .             # all nodes
#
# Add `--- --print-bytecode` etc. by appending after `--`.
{
  self,
  inputs,
  ...
}:
let
  # System target for the Ubuntu server
  system = "x86_64-linux";
  deployLib = inputs.deploy-rs.lib.${system};
in
{
  flake.deploy = {
    nodes = {
      # ---- Node: trikru (Ubuntu 22.04 server — Proxmox VM) ----
      # Standalone home-manager only; no NixOS system profile.
      trikru = {
        hostname = "192.168.0.102";
        sshUser = "thein3rovert";
        # `user` defaults to `sshUser` when set, so the profile is owned by
        # thein3rovert — no sudo needed, no root SSH required.
        sshOpts = [ "-o" "StrictHostKeyChecking=accept-new" ];

        # Build here, push closure over SSH, activate remotely.
        # (Override with `--remote-build` on the CLI if you'd rather build on trikru.)
        remoteBuild = false;

        profiles = {
          home = {
            user = "thein3rovert";
            path = deployLib.activate.home-manager
              self.homeConfigurations."thein3rovert@trikru";
          };
        };
      };
    };
  };

  # Validate `deploy` schema with `nix flake check`
  flake.checks = builtins.mapAttrs
    (s: lib: lib.deployChecks self.deploy)
    inputs.deploy-rs.lib;
}