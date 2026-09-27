{
  config,
  lib,
  self,
  ...
}:
{
  options.homeSetup.thein3rovert.programs.kitty.enable =
    lib.mkEnableOption "Zsh for main user thein3rovert";
  config = lib.mkIf config.homeSetup.thein3rovert.programs.kitty.enable {
    programs.kitty = {
      enable = true;
      settings = {
        # Tokyo Night - ported from .config preview
        background = "#1a1b26";
        foreground = "#c0caf5";
        selection_background = "#7aa2f7";
        selection_foreground = "#1a1b26";
        cursor = "#c0caf5";
        cursor_text_color = "background";

        # Black
        color0 = "#15161e";
        color8 = "#414868";

        # Red
        color1 = "#f7768e";
        color9 = "#f7768e";

        # Green
        color2 = "#9ece6a";
        color10 = "#9ece6a";

        # Yellow
        color3 = "#e0af68";
        color11 = "#e0af68";

        # Blue
        color4 = "#7aa2f7";
        color12 = "#7aa2f7";

        # Magenta
        color5 = "#bb9af7";
        color13 = "#bb9af7";

        # Cyan
        color6 = "#7dcfff";
        color14 = "#7dcfff";

        # White
        color7 = "#a9b1d6";
        color15 = "#c0caf5";

        # Tab colors
        active_tab_foreground = "#16161e";
        active_tab_background = "#7aa2f7";
        inactive_tab_foreground = "#545c7e";
        inactive_tab_background = "#292e42";

        url_color = "#73daca";

        # Other settings
        repaint_delay = "60";
        sync_to_monitor = "no";
        # background_opacity = "1.0";
        # background_blur = "1";
        background_opacity = "0.90";
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
  };
}
