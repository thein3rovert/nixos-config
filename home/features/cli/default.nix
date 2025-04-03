{ pkgs, ... }:
{

  imports = [
    ./zsh.nix
    ./kitty.nix
  ];

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

    # Rust Development
    cargo # Rust package manager and build tool

    # Node.js
    nodejs_23

    wl-clipboard
    xclip

  ];

}
