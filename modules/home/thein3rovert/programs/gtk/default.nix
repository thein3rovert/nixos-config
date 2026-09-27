{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.homeSetup.thein3rovert.programs.gtk.enable =
    lib.mkEnableOption "Tokyo Night GTK theme for main user thein3rovert";

  config = lib.mkIf config.homeSetup.thein3rovert.programs.gtk.enable {
    gtk = {
      enable = true;
      theme = {
        # Provides Tokyonight-Dark / Tokyonight-Light (blue accent default)
        package = pkgs.tokyonight-gtk-theme;
        name = "Tokyonight-Dark";
      };
      # Apply the same theme to GTK4 / libadwaita apps (e.g. Nautilus).
      # HM manages ~/.config/gtk-4.0 itself, so no manual xdg.configFile
      # links (they collide). Explicit to silence the gtk4.theme warning.
      gtk4.theme = config.gtk.theme;
    };
  };
}
