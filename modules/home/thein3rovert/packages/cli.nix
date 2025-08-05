{
  config,
  lib,
  pkgs,
  ...
}:
let
  hostname =
    if (builtins.pathExists ../../../../option.nix) then
      (import ../../../../option.nix).currentHostnames
    else
      # Create the host
      [
        "nixos"
        "welljaha"
      ];
in
{
  options.homeSetup.thein3rovert.packages.cli.enable = lib.mkEnableOption "CLI packages";

  config =
    lib.mkIf
      (
        config.homeSetup.thein3rovert.packages.cli.enable
        &&
          # any: check/iterate over each element in a list (list against list)
          # elem: checks if a single element exit in a list (single values against list)
          # FIX: This works but it only apply to the current host, i
          # it need to be an option so it can be enabled by the other
          # host
          builtins.any (host: builtins.elem host hostname) [
            # Add hostname to apply config to host
            "nixos"
          ]
      )

      {
        # Link to starship config
        # https://github.com/tejing1/nixos-config/blob/fd443fc8706dcd5e700a05421b2eb0ad39517c7d/homeConfigurations/tejing/shell.nix
        programs.starship = {
          enable = true;
          # settings = pkgs.lib.importTOML ../starship.toml;
          settings = {
            add_newline = false;

            format = "[](color_orange)$os$username[](bg:color_yellow fg:color_orange)$directory[](fg:color_yellow bg:color_aqua)$git_branch$git_status[](fg:color_aqua bg:color_blue)$c$cpp$rust$golang$nodejs$php$java$kotlin$haskell$python[](fg:color_blue bg:color_bg3)$docker_context$conda$pixi[](fg:color_bg3 bg:color_bg1)$time[](fg:color_bg1) $line_break$character";

            palette = "gruvbox_dark";

            palettes = {
              gruvbox_dark = {
                color_fg0 = "#fbf1c7";
                color_bg1 = "#3c3836";
                color_bg3 = "#665c54";
                color_blue = "#458588";
                color_aqua = "#689d6a";
                color_green = "#98971a";
                color_orange = "#d65d0e";
                color_purple = "#b16286";
                color_red = "#cc241d";
                color_yellow = "#d79921";
              };
            };

            os = {
              disabled = false;
              style = "bg:color_orange fg:color_fg0";
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
              style_user = "bg:color_orange fg:color_fg0";
              style_root = "bg:color_orange fg:color_fg0";
              format = "[ $user ]($style)";
            };

            directory = {
              style = "fg:color_fg0 bg:color_yellow";
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
              format = "[[ $symbol $branch ](fg:color_fg0 bg:color_aqua)]($style)";
            };

            git_status = {
              style = "bg:color_aqua";
              format = "[[($all_status$ahead_behind )](fg:color_fg0 bg:color_aqua)]($style)";
            };

            nodejs = {
              symbol = "";
              style = "bg:color_blue";
              format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
            };

            c = {
              symbol = " ";
              style = "bg:color_blue";
              format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
            };

            cpp = {
              symbol = " ";
              style = "bg:color_blue";
              format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
            };

            rust = {
              symbol = "";
              style = "bg:color_blue";
              format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
            };

            golang = {
              symbol = "";
              style = "bg:color_blue";
              format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
            };

            php = {
              symbol = "";
              style = "bg:color_blue";
              format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
            };

            java = {
              symbol = "";
              style = "bg:color_blue";
              format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
            };

            kotlin = {
              symbol = "";
              style = "bg:color_blue";
              format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
            };

            haskell = {
              symbol = "";
              style = "bg:color_blue";
              format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
            };

            python = {
              symbol = "";
              style = "bg:color_blue";
              format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
            };

            docker_context = {
              symbol = "";
              style = "bg:color_bg3";
              format = "[[ $symbol( $context) ](fg:#83a598 bg:color_bg3)]($style)";
            };

            conda = {
              style = "bg:color_bg3";
              format = "[[ $symbol( $environment) ](fg:#83a598 bg:color_bg3)]($style)";
            };

            pixi = {
              style = "bg:color_bg3";
              format = "[[ $symbol( $version)( $environment) ](fg:color_fg0 bg:color_bg3)]($style)";
            };

            time = {
              disabled = false;
              time_format = "%R";
              style = "bg:color_bg1";
              format = "[[  $time ](fg:color_fg0 bg:color_bg1)]($style)";
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
        programs.zoxide = {
          enable = true;
          enableZshIntegration = true;
        };

        programs.eza = {
          enable = true;
          enableZshIntegration = true;
          enableBashIntegration = true;
          extraOptions = [
            "-l"
            "--icons"
            "--git"
            "-a"
          ];
        };

        programs.bat = {
          enable = true;
        };

        programs.fzf = {
          enable = true;
          enableZshIntegration = true;
        };

        programs = {
          direnv = {
            enable = true;
            nix-direnv.enable = true;
          };
        };

        home.packages = with pkgs; [
          # Core Utilities
          coreutils # Basic file, shell, and text manipulation utilities
          fd # Fast and user-friendly alternative to `find`
          htop # Interactive process viewer
          lsof # List open files
          tree # Display directories as trees
          zip # Compression utility
          unzip # Decompression utility

          # Networking and HTTP Tools
          httpie # Command-line HTTP client

          # Text Processing
          jq # Command-line JSON processor
          rclone
          ripgrep # Fast search tool like `grep`
          tldr # Simplified and community-driven man pages

          # Shell and Prompt Customization
          oh-my-posh # Prompt theme engine for any shell

          # System Information
          fastfetch # Neofetch-like tool for system information

          # Desktop Utilities
          swww # Wallpaper setter (move to desktop folder)
          pomodoro-gtk # Pomodoro timer with GTK interface

          # Neovim and Development Tools
          lua-language-server # Language server for Lua
          lua51Packages.lua # Lua 5.1 interpreter
          gccgo14 # Go compiler (GCC-based)
          luajitPackages.luarocks # Lua package manager
          tree-sitter # Parser generator tool and library
          vimPlugins.luasnip # Snippet engine for Neovim
          python312Packages.pip # Python package manager
          prettierd # Prettier daemon for formatting
          luajitPackages.jsregexp # JavaScript regular expressions for LuaJIT
          nil # Neovim LSP configuration tool
          nixfmt-rfc-style

          # Rust Development
          cargo # Rust package manager and build tool

          # Node.js
          nodejs_24

          wl-clipboard
          xclip
          tmux

          # Azure
          azure-cli

        ];

      };
}
