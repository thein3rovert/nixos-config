#INFO: This file holds common configuration for all hosts
{
  lib,
  inputs,
  outputs,
  pkgs,
  ...
}:

{
  # === Import modules and Home Manager ===
  imports = [
    ./users
    ./extraServices
    inputs.home-manager.nixosModules.home-manager
  ];

  # === Configure Home Manager ===
  home-manager = {
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs outputs; # === Make flake inputs/outputs available in Home Manager ===
    };
  };

  # === Configure nixpkgs with overlays and unfree packages ===
  nixpkgs = {
    overlays = [
      outputs.overlays.additions # === Custom package additions ===
      outputs.overlays.modifications # === Custom package modifications ===
      outputs.overlays.stable-packages # === Stable package versions ===
    ];
    config = {
      allowUnfree = true; # === Allow use of unfree packages ===
    };
  };

  # === Global Nix configuration ===
  nix = {
    settings = {
      experimental-features = "nix-command flakes"; # === Enable flakes and nix-command ===
      trusted-users = [
        "root"
        "thein3rovert"
      ]; # === Users allowed to run nix commands ===
    };

    # === Enable automatic garbage collection ===
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };

    # === Enable automatic store optimization ===
    optimise.automatic = true;

    # === Register all flake inputs as nix registry entries ===
    registry = lib.mapAttrs (_: flake: { inherit flake; }) (
      lib.filterAttrs (_: lib.isType "flake") inputs
    );

    # === Set custom NIX_PATH ===
    nixPath = [ "/etc/nix/path" ];
  };

  # === Default user shell ===
  # NOTE: This is disabled to prevent Zsh from being inherited on remote VMs during deployment
  # users.defaultUserShell = pkgs.zsh;
}
