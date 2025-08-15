{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Handled and managed by nixos services
  options.nixosSetup.programs.vscode.enable =
    lib.mkEnableOption "Vscode and FSH support for vscode server";

  config = lib.mkIf config.nixosSetup.programs.vscode.enable {
  #  environment.systemPackages = with pkgs; [ vscode ];
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
  };
}
