{
  config,
  lib,
  inputs,
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
  config = lib.mkIf config.myUsers.thein3rovert.enable {
    users.users.thein3rovert = {
      description = "Danny thein3rovert"; # Change this to match all, reduce conflit
      extraGroups = config.myUsers.defaultGroups;
      hashedPassword = config.myUsers.thein3rovert.password;
      isNormalUser = true;
      uid = 1000;

      # Fixes home-manager not showing after enabled error
      packages = [ inputs.home-manager.packages.${pkgs.stdenv.hostPlatform.system}.default ];

      # Management
      openssh.authorizedKeys.keys = [
        ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIObli1unUWlbZaja5VMzTIvPBJOCI/E6vs/qhrVkSHLO thein3rovert''
      ];

      # === Enable ssh config when installed ===
      # shell = pkgs.zsh;

      openssh.authorizedKeys.keyFiles = createMap (file: "${self.inputs.secrets}/publicKeys/${file}") (
        filterOut (file: containThePrefix "thein3rovert_" file) (
          builtins.attrNames (builtins.readDir "${self.inputs.secrets}/publicKeys")
        )
      );

    };

    # === Disable root password ===
    # = Colmena doos not support password =
    security.sudo.extraRules = [
      {
        users = [ "thein3rovert" ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };

}
