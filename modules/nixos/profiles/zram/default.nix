{
  config,
  lib,
  ...
}:
{
  options.nixosSetup.profiles.zram.enable = lib.mkEnableOption "zram swap";

  config = lib.mkIf config.nixosSetup.profiles.zram.enable {
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      priority = 100;
    };
  };
}
