{
  config,
  lib,
  ...
}:
let
  cfg = config.coreModules.programs;
in
{
  options.coreModules.programs.enable = lib.mkEnableOption "Enable my core programs modules";

  # Can this config be any variable
  config = lib.mkIf cfg.enable {
    # TODO: Move to respective modules later

    programs.firefox.enable = false;

    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    programs.zsh.enable = true;

  };

}
