{
  config,
  lib,
  pkgs,
  self,
  ...
}:
{
  imports = [
    ./thein3rovert
    ./options.nix
  ];
  config =
    lib.mkIf
      (config.myUsers.root.enable or config.myUsers.thein3rovert.enable # or config.myUsers.newUser.enable
      )
      {

        # === PROGRAM ===
        # programs.zsh.enable = true;

        users = {
          mutableUsers = false;
          # defaultUserShell = pkgs.zsh;
          users.root.openssh.authorizedKeys.keys = [
            ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGKcMZafP6nbYGk5MKxll1GkI/JKesULVmHL0ragX0Qe''
          ];
        };
      };
}
