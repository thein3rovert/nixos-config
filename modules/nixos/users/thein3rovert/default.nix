{
  config,
  lib,
  pkgs,
  self,
  ...
}:
{
  config = lib.mkIf config.myUsers.thein3rovert.enable {
    users.users.thein3rovert = {
      description = "Danny thein3rovert";
      extraGroups = config.myUsers.defaultGroups;
      hashedPassword = config.myUsers.thein3rovert.password;
      isNormalUser = true;

      # openssh.authorizedKeys.keyFiles = lib.map (file: "${self.inputs.secrets}/publicKeys/${file}") (
      #   lib.filter (file: lib.hasPrefix "aly_" file) (
      #     builtins.attrNames (builtins.readDir "${self.inputs.secrets}/publicKeys")
      #   )
      # );
      # TODO: Find and Replace ID and Keep shell as BASH
      # shell = pkgs.zsh;
      # uid = 1000;
    };
  };
}
