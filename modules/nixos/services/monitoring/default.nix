{ lib, ... }:
{
  imports = [
    ./glance
    ./uptime-kuma
    ./grafana
    ./promtail
    ./prometheusNode
    ./dockhand
    ./hawser
    ./zerobyte
  ];
}
