{
  config,
  lib,
  pkgs,
  ...
}:
let
  # So we dont repeat the packages
  fhsLib = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    openssl
    libkrb5
    util-linux
    glibc
  ];
in
{
  # Handled and managed by nixos services
  options.nixosSetup.programs.vscode = {
    enable = lib.mkEnableOption "Vscode and FSH support for vscode server";
    # Reference: https://github.com/alyraffauf/nixcfg/blob/master/modules/nixos/services/tailscale/default.nix

    vscodePackage = lib.mkOption {
      description = "Vscode Packages";
      default = pkgs.vscode;
      type = lib.types.package;
    };

    enableFhs = lib.mkOption {
      description = "Enable FHS support only (nix-ld libraries) without installing VSCode";
      default = false;
      type = lib.types.bool;
    };
  };

  config = lib.mkMerge [

    # If vscode is enable install vscode and FSH packages
    (lib.mkIf config.nixosSetup.programs.vscode.enable {

      environment.systemPackages = [
        config.nixosSetup.programs.vscode.vscodePackage
      ];

      # Enable FHS compatibility for VS Code Server
      programs.nix-ld.enable = true;
      programs.nix-ld.libraries = with pkgs; [
        stdenv.cc.cc.lib
        zlib
        openssl
        libkrb5
        util-linux
        glibc
      ];
    })

    # If vscode server fhs is enable and vscode is not enabled
    # install the packages
    # Fix: Wrong logic, they should be independent of each other
    (lib.mkIf (config.nixosSetup.programs.vscode.enableFhs && !config.nixosSetup.programs.vscode.enable)
      {
        programs.nix-ld.enable = true;
        programs.nix-ld.libraries = with pkgs; [
          stdenv.cc.cc.lib
          zlib
          openssl
          libkrb5
          util-linux
          glibc
        ];
      }
    )
  ];
}
