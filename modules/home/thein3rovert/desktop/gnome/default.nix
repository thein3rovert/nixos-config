{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.homeSetup.thein3rovert.desktop.gnome = {
    /*
      NOTE:
      nix.mkOption is used to define configuration options in Nix,
      specifying their type, default value, and documentation for
      modular and declarative setups.enable
    */
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.homeSetup.desktop.gnome.enable && config.home.username == "thein3rovert";
      description = "Enable thein3rovert's GNOME desktop environment.";
    };
  };

  config = lib.mkIf config.homeSetup.desktop.gnome.enable {
    dconf = {
      enable = true;

      # dconf settings
      settings = {
        "org/gnome/shell" = {
          favorite-apps = [
            "zen-beta.desktop"
            "thunderbird.desktop"
            "signal.desktop"
            "vesktop.desktop"
            "obsidian.desktop"
            "com.mitchellh.ghostty.desktop"
            "dev.zed.Zed.desktop"
            "org.gnome.Nautilus.desktop"
          ];
        };

        "org/gnome/shell/extensions/auto-move-windows" = {
          application-list = [
            "code.desktop:3"
            "obsidian.desktop:2"
            "plexamp.desktop:1"
            "signal.desktop:1"
            "thunderbird.desktop:4"
            "vesktop.desktop:1"
            "zen-beta.desktop:1"
            "zen-twilight.desktop:1"
          ];
        };
      };
    };

    programs.gnome-shell = {
      enable = true;

      extensions = [
        { package = pkgs.gnomeExtensions.bluetooth-battery-meter; }
        { pakage = pkgs.gnomeExtensions.vscode-search-provider; }
      ];
    };
  };
}
