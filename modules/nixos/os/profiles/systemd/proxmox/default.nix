{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    ;
  If = mkIf;
  createEnableOption = mkEnableOption;
  cfg = config.nixosSetup.profiles.proxmox;

  proxmox_secret_file = config.age.secrets.proxmox_api_secrets.path;
in
{
  options.nixosSetup.profiles.proxmox.enable = createEnableOption "Proxmox credentials";
  config = If cfg.enable {
    systemd.user.services.installProxmoxSecrets = {
      description = "Install Proxmox API secrets file";
      after = [ "default.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = ''
          cp ${proxmox_secret_file} $HOME/.proxmox_api_secrets
          chmod 600 $HOME/.proxmox_api_secrets
        '';
      };
      wantedBy = [ "default.target" ];
    };
  };
}
