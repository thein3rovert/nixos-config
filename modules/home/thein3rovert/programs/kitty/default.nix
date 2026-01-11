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
        # Custom color scheme
        background = "#1d2021";
        foreground = "#d4be98";
        selection_background = "#d4be98";
        selection_foreground = "#1d2021";
        cursor = "#a89984";
        cursor_text_color = "background";

        # Black
        color0 = "#665c54";
        color8 = "#928374";

        # Red
        color1 = "#ea6962";
        color9 = "#ea6962";

        # Green
        color2 = "#a9b665";
        color10 = "#a9b665";

        # Yellow
        color3 = "#e78a4e";
        color11 = "#d8a657";

        # Blue
        color4 = "#83a598";
        color12 = "#83a598";

        # Magenta
        color5 = "#d3869b";
        color13 = "#d3869b";

        # Cyan
        color6 = "#89b482";
        color14 = "#89b482";

        # White
        color7 = "#d4be98";
        color15 = "#d4be98";

        # Tab colors
        active_tab_foreground = "#444444";
        active_tab_background = "#d4be98";
        inactive_tab_foreground = "#d4be98";
        inactive_tab_background = "#171a1a";

        url_color = "#d3869b";

        # Other settings
        repaint_delay = "60";
        sync_to_monitor = "no";
        # background_opacity = "1.0";
        # background_blur = "1";
        background_opacity = "0.80";
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
