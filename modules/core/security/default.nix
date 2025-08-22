{
  config,
  lib,
  ...
}:
let
  cfg = config.coreModules.security;
in
{
  options.coreModules.security.enable = lib.mkEnableOption "Enable my core security module";

  # Can this config be any variable
  config = lib.mkIf cfg.enable {

    security.rtkit.enable = true;
    # Allow passwordless actions
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
