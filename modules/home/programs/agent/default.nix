{ pkgs, ... }:
{
  imports = [
    ./opencode.nix
  ];
  home.packages = with pkgs; [
    # agenix-cli
    # beads
    # bc
    bun
    # claude-code
    # devpod
    #devpod-desktop
    # code2prompt
    # nur.repos.charmbracelet.crush
    (python3.withPackages (
      ps: with ps; [
        pip
        # uv

        # Scientific packages
        # numba
        # numpy
        # torch
        # srt
      ]
    ))
    nixd
    alejandra
  ];
}
