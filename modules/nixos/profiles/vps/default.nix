{
  config,
  lib,
  ...
}:
{
  options.nixosSetup.profiles.vps.enable = lib.mkEnableOption "vps optimizations";

  config = lib.mkIf config.nixosSetup.profiles.vps.enable {
    documentation = {
      enable = false;
      nixos.enable = false;
    };

    services.journald = {
      storage = "auto";

      extraConfig = ''
        SystemMaxUse=500M
        MaxRetentionSec=1week
      '';
    };
  };
}
