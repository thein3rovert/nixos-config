{ lib, config, ... }:
let
  inherit (lib)
    mkOption
    types
    ;
in
{
  imports = [
    ./ip-registry.nix
    ./ip-addresses.nix
  ];

  # ============================================
  # Ports Configuration Options
  #
  # /*
  #  containerPorts: Ports used by Podman containers
  #  servicePorts: Ports used by system services
  #  customPorts: Ports used by custom applications
  # */
  #
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
  #
  # /*
  #  All port definitions are centralized here
  #  to be used across the entire configuration
  # */
  #
  # ============================================
  config.homelab = {
    # ============================================
    # Container Ports
    #
    # /* Podman container service ports
    # */
    #
    # ============================================
    containerPorts = {
      # Bookmarking & Links
      linkding = 9090;

      # Blogging & CMS
      blog = 8084;

      # Monitoring
      uptime-kuma = 8380;

      # RSS & News
      freshrss = 8083;
      jotty = 8382;

      # Security
      vault = 8200;

      # Storage
      memos = 5230;
      copyparty = 3923;

      # Web Applications
      zerobyte = 4096;
      dockhand = 3000;
      fossflow = 8087;
      ad-guard = 3000;
      glance = 8280;
      rancher = 3909;
    };

    # ============================================
    # Service Ports
    #
    # /* System service ports
    # */
    #
    # ============================================
    servicePorts = {
      # DNS
      adguard = 53;

      # Database
      postgresql = 5432;

      # Development
      forgejo = 3002;
      n8n = 5678;

      # Logging & Monitoring
      grafana = 3010;
      loki = 3030;
      promtail = 3031;
      prometheusNode = 3021;
      prometheus = 3020;

      # Networking
      traefik = 80;
      ssh = 22;
      ssh-forgejo = 2222;

      # Container Management
      hawser = 2376;

      # Storage
      garage-api = 3900;
      garage-webui = 3909;
      minio = [
        3007
        3008
      ];
    };

    # ============================================
    # Custom Ports
    #
    # /* Additional custom application ports
    # */
    #
    # ============================================
    customPorts = {
      ipam = 5050;
      api = 4873;
    };
  };
}
