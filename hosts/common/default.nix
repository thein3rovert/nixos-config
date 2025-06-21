#INFO: This file holds common configuration for all hosts
{
  lib,
  inputs,
  outputs,
  pkgs,
  ...
}:
{
  imports = [
    ./users
    ./extraServices
    inputs.home-manager.nixosModules.home-manager
  ];

  # Make flake input/output available to home manager
  home-manager = {
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs outputs; };
  };

  nixpkgs = {
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.stable-packages
    ];
    config = {
      allowUnfree = true;
    };
  };

  # User allowed to use the flake command
  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      trusted-users = [
        "root"
        "thein3rovert"
      ];
    };

    # Automatic System Cleaning
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
    optimise.automatic = true;
    registry = (lib.mapAttrs (_: flake: { inherit flake; })) (
      (lib.filterAttrs (_: lib.isType "flake")) inputs
    );

    # Nix path
    nixPath = [ "/etc/nix/path" ];
  };

  #INFO: Disabled so remote vm dont inherit zsh on deployment
  # users.defaultUserShell = pkgs.zsh;
}
