{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkDefault
    mkIf
    ;
  If = mkIf;
  setDefault = mkDefault;
  createEnableOption = mkEnableOption;
  cfg = config.nixosSetup.profiles.proxmox;

  secretFile = pkgs.writeText "proxmox_api_secrets" ''
    export ROOT_PASSWORD="your_secure_root_password"
    export PM_API_URL="https://192.168.0.99:8006/api2/json"
    export PM_API_TOKEN_ID="terraform-prov@pve!terraform-token"
    export PM_API_TOKEN_SECRET="MY_VERY_SECRET_TOKEN"
    export PM_TLS_INSECURE="true"
  '';
in
{
  options.nixosSetup.profiles.proxmox.enable = createEnableOption "Proxmox credentials";
  config = If cfg.enable {
    systemd.user.services.installProxmoxSecrets = {
      description = "Install Proxmox API secrets file";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = ''
          cp ${secretFile} $HOME/.proxmox_api_secrets
          chmod 600 $HOME/.proxmox_api_secrets
        '';
      };
      wantedBy = [ "default.target" ];
    };
  };
}
