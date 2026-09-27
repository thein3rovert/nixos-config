{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.homeSetup.thein3rovert.programs.starship.enable =
    lib.mkEnableOption "Zsh for main user thein3rovert";

  config = lib.mkIf (config.homeSetup.thein3rovert.programs.starship.enable) {

    # https://github.com/tejing1/nixos-config/blob/fd443fc8706dcd5e700a05421b2eb0ad39517c7d/homeConfigurations/tejing/shell.nix
    programs.starship = {
      enable = true;
      # settings = pkgs.lib.importTOML ../starship.toml;
      settings = {
        add_newline = false;

        format = "[](color_orange)$os$username[](bg:color_yellow fg:color_orange)$directory[](fg:color_yellow bg:color_aqua)$git_branch$git_status[](fg:color_aqua bg:color_blue)$c$cpp$rust$golang$nodejs$php$java$kotlin$haskell$python[](fg:color_blue bg:color_bg3)$docker_context$conda$pixi[](fg:color_bg3 bg:color_bg1)$time[](fg:color_bg1) $line_break$character";

        palette = "tokyo_night";

        palettes = {
          tokyo_night = {
            color_fg0 = "#c0caf5";
            color_bg1 = "#565f89";
            color_bg3 = "#414868";
            color_blue = "#7aa2f7";
            color_aqua = "#7dcfff";
            color_green = "#9ece6a";
            color_orange = "#ff9e64";
            color_purple = "#bb9af7";
            color_red = "#f7768e";
            color_yellow = "#e0af68";
          };
        };

        os = {
          disabled = false;
          style = "bg:color_orange fg:#1a1b26";
          symbols = {
            Windows = "󰍲";
            Ubuntu = "󰕈";
            SUSE = "";
            Raspbian = "󰐿";
            Mint = "󰣭";
            Macos = "󰀵";
            Manjaro = "";
            Linux = "󰌽";
            Gentoo = "󰣨";
            Fedora = "󰣛";
            Alpine = "";
            Amazon = "";
            Android = "";
            Arch = "󰣇";
            Artix = "󰣇";
            EndeavourOS = "";
            CentOS = "";
            Debian = "󰣚";
            Redhat = "󱄛";
            RedHatEnterprise = "󱄛";
            Pop = "";
          };
        };

        username = {
          show_always = true;
          style_user = "bg:color_orange fg:#1a1b26";
          style_root = "bg:color_orange fg:#1a1b26";
          format = "[ $user ]($style)";
        };

        directory = {
          style = "fg:#1a1b26 bg:color_yellow";
          format = "[ $path ]($style)";
          truncation_length = 3;
          truncation_symbol = "…/";
          substitutions = {
            "Documents" = "󰈙 ";
            "Downloads" = " ";
            "Music" = "󰝚 ";
            "Pictures" = " ";
            "Developer" = "󰲋 ";
          };
        };

        git_branch = {
          symbol = "";
          style = "bg:color_aqua";
          format = "[[ $symbol $branch ](fg:#1a1b26 bg:color_aqua)]($style)";
        };

        git_status = {
          style = "bg:color_aqua";
          format = "[[($all_status$ahead_behind )](fg:#1a1b26 bg:color_aqua)]($style)";
        };

        nodejs = {
          symbol = "";
          style = "bg:color_blue";
          format = "[[ $symbol( $version) ](fg:#1a1b26 bg:color_blue)]($style)";
        };

        c = {
          symbol = " ";
          style = "bg:color_blue";
          format = "[[ $symbol( $version) ](fg:#1a1b26 bg:color_blue)]($style)";
        };

        cpp = {
          symbol = " ";
          style = "bg:color_blue";
          format = "[[ $symbol( $version) ](fg:#1a1b26 bg:color_blue)]($style)";
        };

        rust = {
          symbol = "";
          style = "bg:color_blue";
          format = "[[ $symbol( $version) ](fg:#1a1b26 bg:color_blue)]($style)";
        };

        golang = {
          symbol = "";
          style = "bg:color_blue";
          format = "[[ $symbol( $version) ](fg:#1a1b26 bg:color_blue)]($style)";
        };

        php = {
          symbol = "";
          style = "bg:color_blue";
          format = "[[ $symbol( $version) ](fg:#1a1b26 bg:color_blue)]($style)";
        };

        java = {
          symbol = "";
          style = "bg:color_blue";
          format = "[[ $symbol( $version) ](fg:#1a1b26 bg:color_blue)]($style)";
        };

        kotlin = {
          symbol = "";
          style = "bg:color_blue";
          format = "[[ $symbol( $version) ](fg:#1a1b26 bg:color_blue)]($style)";
        };

        haskell = {
          symbol = "";
          style = "bg:color_blue";
          format = "[[ $symbol( $version) ](fg:#1a1b26 bg:color_blue)]($style)";
        };

        python = {
          symbol = "";
          style = "bg:color_blue";
          format = "[[ $symbol( $version) ](fg:#1a1b26 bg:color_blue)]($style)";
        };

        docker_context = {
          symbol = "";
          style = "bg:color_bg3";
          format = "[[ $symbol( $context) ](fg:#1a1b26 bg:color_bg3)]($style)";
        };

        conda = {
          style = "bg:color_bg3";
          format = "[[ $symbol( $environment) ](fg:#1a1b26 bg:color_bg3)]($style)";
        };

        pixi = {
          style = "bg:color_bg3";
          format = "[[ $symbol( $version)( $environment) ](fg:#1a1b26 bg:color_bg3)]($style)";
        };

        time = {
          disabled = false;
          time_format = "%R";
          style = "bg:color_bg1";
          format = "[[  $time ](fg:#1a1b26 bg:color_bg1)]($style)";
        };

        line_break = {
          disabled = false;
        };

        character = {
          disabled = false;
          success_symbol = "[](bold fg:color_green)";
          error_symbol = "[](bold fg:color_red)";
          vimcmd_symbol = "[](bold fg:color_green)";
          vimcmd_replace_one_symbol = "[](bold fg:color_purple)";
          vimcmd_replace_symbol = "[](bold fg:color_purple)";
          vimcmd_visual_symbol = "[](bold fg:color_yellow)";
        };
        gcloud = {
          detect_env_vars = [ "GOOGLE_CLOUD" ];
        };
        aws = {
          disabled = true;
        };
      };
    };

  };
}
