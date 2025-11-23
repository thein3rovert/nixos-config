{
  config,
  lib,
  pkgs,
  self,
  ...
}:
let
  inherit (lib)
    map
    filter
    hasPrefix
    ;

  createMap = map;
  filterOut = filter;
  containThePrefix = hasPrefix;
in
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
          users.root.openssh.authorizedKeys = {
            keyFiles = createMap (file: "${self.inputs.secrets}/publicKeys/${file}") (
              filterOut (file: containThePrefix "thein3rovert_" file) (
                builtins.attrNames (builtins.readDir "${self.inputs.secrets}/publicKeys")
              )
            );
            keys = [
              ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIObli1unUWlbZaja5VMzTIvPBJOCI/E6vs/qhrVkSHLO thein3rovert''
            ];
          };
        };
      };
}
