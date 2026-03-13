{ lib, config, ... }:
let
  inherit (lib)
    mkOption
    types
    ;

  string = types.str;
  listOf = types.listOf;
  attributeSetOf = types.attrsOf;
in
{
  imports = [
    ./ip-registry.nix
    ./ip-addresses.nix
  ];
  # ============================================
  # Ports Configuration Options
  # ============================================
  options.homelab = {
    containerPorts = mkOption {
      type = types.attrsOf (types.either types.int (types.listOf types.int));
      default = { };
      description = "Ports used by Nixos Podman Containers";
    };

    servicePorts = mkOption {
      type = types.attrsOf (types.either types.int (types.listOf types.int));
      default = { };
      description = "Ports used by Nixos Podman services";
    };

    customPorts = mkOption {
      type = types.attrsOf types.int;
      default = { };
      description = "Ports used by custom Services and Applications";
    };
  };

  # ============================================
  # Ports Configuration
  # ============================================
  config.homelab = {
    containerPorts = {
      linkding = 9090;
      zerobyte = 4096;
      uptime-kuma = 8380;
      freshrss = 8083;
      jotty = 8382;
      dockhand = 3000;
      fossflow = 8087;
      ad-guard = 3000;
      vault = 8200;
      memos = 5230;
      blog = 8084;
      glance = 8280;
      rancher = 3909;
    };

    servicePorts = {
      traefik = 80;
      adguard = 53;
      ssh = 22;
      ssh-forgejo = 2222;
      garage-api = 3900;
      minio = [
        3007
        3008
      ];
      postgresql = 5432;
      forgejo = 3002;
      n8n = 5678;
      garage-webui = 3909;
      hawser = 2376;
      grafana = 3010;
      loki = 3030;
      promtail = 3031;
      prometheusNode = 3021;
      prometheus = 3020;

    };

    customPorts = {
      ipam = 5050;
      api = 4873;
    };
  };
}
