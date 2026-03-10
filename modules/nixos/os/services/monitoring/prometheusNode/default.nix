{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkIf
    ;

  If = mkIf;

  cfg = config.nixosSetup.services.prometheusNode;
in
{
  options.nixosSetup.services.prometheusNode = {
    enable = lib.mkEnableOption "prometheus node exporter for monitoring system metrics";
  };

  config = If cfg.enable {
    services.prometheus.exporters.node = {
      enable = true;
      enabledCollectors = [ "systemd" ];

      extraFlags = [
        "--collector.ethtool"
        "--collector.softirqs"
        "--collector.tcpstat"
        "--collector.wifi"
      ];

      port = 3021;
    };
  };
}
