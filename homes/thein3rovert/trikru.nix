# ============================================================================
# HOST-SPECIFIC HOME-MANAGER CONFIG: trikru (Ubuntu 22.04 server, Proxmox VM)
# ============================================================================
# This is a STANDALONE home-manager config (not NixOS integration).
# Activate with: home-manager switch --flake .#thein3rovert@trikru
#
# 📖 See docs: `doc-001 - Home-Manager-Configuration-Architecture.md`
#
# HOW IT'S LOADED:
#   modules/flake/home-manager.nix loads this file AFTER
#   self.homeManagerModules.thein3rovert (the base config), so anything
#   defined here MERGES with / OVERRIDES the base.
#
# ⚠️ DO NOT wrap config in `home-manager.users.thein3rovert = { ... }`.
#    That option only exists in NixOS integration mode. In standalone mode
#    you configure home-manager DIRECTLY at the root level.
#
# TO OVERRIDE A BASE VALUE:
#   Use `lib.mkForce` for scalars (e.g. stateVersion).
#   Lists (like packages) automatically concatenate with the base.
# ============================================================================
{
  pkgs,
  lib,
  self,
  ...
}:
{
  # Host-specific packages (added on top of base packages from default.nix)
  home.packages = with pkgs; [ vim ];

  # Override base stateVersion (base = "25.11", this host = "25.05")
  home.stateVersion = lib.mkForce "25.05";

  # Enable zsh for this host
  programs.zsh.enable = true;

  homeSetup.programs = {
    # Main opencode config
    opencode = {
      enable = true;
    };
    # Opencode agent config
    # This is independent of the agent config
    agent = {
      enable = true;
      agentsInput = self.inputs.polis;

      opencode = {
        enable = true;
        agentsInput = self.inputs.polis;
        modelOverrides = {
          ag-quick-chat = "opencode-go/deepseek-v4";
          ag-blog-writer = "anthropic/claude-sonnet-4";
        };
      };
    };
  };
}
