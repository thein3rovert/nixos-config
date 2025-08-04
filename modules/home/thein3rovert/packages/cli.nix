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
