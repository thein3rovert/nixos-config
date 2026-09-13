{ lib, ... }:
{
  imports = [
    ./glance
    ./uptime-kuma
    ./grafana
    ./promtail
    ./vector
    ./prometheusNode
    ./dockhand
    ./hawser
    ./zerobyte
  ];
}
