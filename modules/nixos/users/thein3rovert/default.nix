{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.myUsers.thein3rovert.enable {
    users.users.thein3rovert = {
      description = "Danny thein3rovert"; # Change this to match all, reduce conflit
      extraGroups = config.myUsers.defaultGroups;
      hashedPassword = config.myUsers.thein3rovert.password;
      isNormalUser = true;
      uid = 1000;

      # Fixes home-manager not showing after enabled error
      packages = [ inputs.home-manager.packages.${pkgs.system}.default ];

      openssh.authorizedKeys.keys = [
        ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGKcMZafP6nbYGk5MKxll1GkI/JKesULVmHL0ragX0Qe''
      ];

      # === Enable ssh config when installed ===
      # shell = pkgs.zsh;

      # === KISS ==
      # openssh.authorizedKeys.keyFiles = lib.map (file: "${self.inputs.secrets}/publicKeys/${file}") (
      #   lib.filter (file: lib.hasPrefix "aly_" file) (
      #     builtins.attrNames (builtins.readDir "${self.inputs.secrets}/publicKeys")
      #   )
      # );

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
