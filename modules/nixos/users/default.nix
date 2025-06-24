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
        # programs.zsh.enable = true;

        users = {
          # defaultUserShell = "bash";
          mutableUsers = false;

          # users.root.openssh.authorizedKeys.keyFiles =
          #   lib.map (file: "${self.inputs.secrets}/publicKeys/${file}")
          #     (
          #       lib.filter (file: lib.hasPrefix "aly_" file) (
          #         builtins.attrNames (builtins.readDir "${self.inputs.secrets}/publicKeys")
          #       )
          #     );
        };
      };
}
