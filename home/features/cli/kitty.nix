{
  config,
  inputs,
  self,
  ...
}:

{
  imports = [
    self.inputs.nix-colors.homeManagerModule
  ];

  colorScheme = self.inputs.nix-colors.colorSchemes.gruvbox-dark-medium;
  programs.kitty = {
    enable = true;
    settings = {
      active_tab_foreground = "#${config.colorScheme.palette.base00}";
      active_tab_background = "#${config.colorScheme.palette.base0D}";

      foreground = "#${config.colorScheme.palette.base05}";
      background = "#${config.colorScheme.palette.base00}";
      url_color = "#${config.colorScheme.palette.base0E}";

      color0 = "#${config.colorScheme.palette.base00}"; # black
      color1 = "#${config.colorScheme.palette.base08}"; # red
      color2 = "#${config.colorScheme.palette.base0B}"; # green
      color3 = "#${config.colorScheme.palette.base0A}"; # yellow
      color4 = "#${config.colorScheme.palette.base0D}"; # blue
      color5 = "#${config.colorScheme.palette.base0E}"; # magenta
      color6 = "#${config.colorScheme.palette.base0C}"; # cyan
      color7 = "#${config.colorScheme.palette.base05}"; # white
      # terminal16
      color8 = "#${config.colorScheme.palette.base03}"; # bright black
      color9 = "#${config.colorScheme.palette.base08}"; # bright red
      color10 = "#${config.colorScheme.palette.base0B}"; # bright green
      color11 = "#${config.colorScheme.palette.base0A}"; # bright yellow
      color12 = "#${config.colorScheme.palette.base0D}"; # bright blue
      color13 = "#${config.colorScheme.palette.base0E}"; # bright magenta
      color14 = "#${config.colorScheme.palette.base0C}"; # bright cyan
      color15 = "#${config.colorScheme.palette.base07}"; # bright white
      #
      repaint_delay = "60";
      sync_to_monitor = "no"; # Performance
      background_opacity = "1.0";
      background_blur = "1";
      tab_bar_style = "powerline";
      tab_powerline_style = "round";
      font_family = "JetbrainsMono Nerd Font";
      bold_font = "auto";
      italic_font = "JetBrainsMono NFM Italic";
      bold_italic_font = "JetBrainsMono NFM Bold Italic";
      font_size = "10.0";
      cursor_shape = "beam";
      cursor_beam_thickness = "0.5";
      cursor_blink_interval = "0.5";
      strip_trailing_spaces = "always";
      update_check_interval = "0";
      window_padding_width = "30";
      initial_window_width = "78c";
      initial_window_height = "23c";
    };
  };
}
