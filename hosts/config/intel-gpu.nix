{
  pkgs,
  config,
  lib,
  ...
}:

let
  inherit (import ../../options.nix) gpuType;
in
lib.mkIf ("${gpuType}" == "intel") {
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override {
      enableHybridCodec = true;
    };
  };

  # OpenGL
  hardware.graphics = {
    extraPackages = with pkgs; [
      intel-media-driver

      # Native Intel drivers best for GPUs
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl

      # Core Intel driver
      libva
      libva-utils
    ];
  };
}
