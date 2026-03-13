{ config, lib, ... }:
let
  inherit (lib)
    mkOption
    types
    ;

  createOption = mkOption;
  string = types.str;
  list = types.attrs;

  homelab = config.homelab;
  ports = config.homelab;
in
{
  # ============================================
  # Network Map Options
  # ============================================
  options.myDns.networkMap = {
    name = createOption {
      default = "${homelab.domain.local}";
      description = "Local DNS domain name";
      type = string;
    };

    localNetworkMap = createOption {
      type = list;
      description = "Hostnames, ports, and vHosts for ${config.myDns.networkMap.name} services.";

      default = {
        # ============================================
        # Bookmarking & Links
        # ============================================
        linkding = {
          hostName = "wellsjaha";
          port = ports.containerPorts.linkding;
          vHost = "linkding.${config.myDns.networkMap.name}";
        };

        # ============================================
        # Ad-Blocking & DNS
        # ============================================
        adguard = {
          hostName = "emily";
          port = ports.servicePorts.adguard;
          vHost = "adguard.${config.myDns.networkMap.name}";
        };
        ad-guard = {
          hostName = "finn";
          port = ports.containerPorts.ad-guard;
          vHost = "ad-guard.${config.myDns.networkMap.name}";
        };

        # ============================================
        # Automation
        # ============================================
        n8n = {
          hostName = "emily";
          port = ports.servicePorts.n8n;
          vHost = "n8n.${config.myDns.networkMap.name}";
        };

        # ============================================
        # Container Management
        # ============================================
        incus = {
          hostName = "emily";
          port = 8443;
          vHost = "incus.${config.myDns.networkMap.name}";
        };
        rancher = {
          hostName = "marcus";
          port = ports.containerPorts.rancher;
          vHost = "rancher.${config.myDns.networkMap.name}";
        };

        # ============================================
        # Database
        # ============================================
        postgres = {
          hostName = "emily";
          port = ports.servicePorts.postgresql;
          vHost = "postgres.${config.myDns.networkMap.name}";
        };

        # ============================================
        # Development
        # ============================================
        dockhand = {
          hostName = "emily";
          port = ports.containerPorts.dockhand;
          vHost = "dockhand.${config.myDns.networkMap.name}";
        };
        hawser = {
          hostName = "emily";
          port = ports.servicePorts.hawser;
          vHost = "hawser.${config.myDns.networkMap.name}";
        };

        # ============================================
        # Logging & Monitoring
        # ============================================
        grafana = {
          hostName = "emily";
          port = ports.servicePorts.grafana;
          vHost = "grafana.${config.myDns.networkMap.name}";
        };
        prometheus = {
          hostName = "emily";
          port = ports.servicePorts.prometheus;
          vHost = "prometheus.${config.myDns.networkMap.name}";
        };
        prometheusNode = {
          hostName = "emily";
          port = ports.servicePorts.prometheusNode;
          vHost = "prometheusNode.${config.myDns.networkMap.name}";
        };
        promtail = {
          hostName = "emily";
          port = ports.servicePorts.promtail;
          vHost = "promtail.${config.myDns.networkMap.name}";
        };
        loki = {
          hostName = "emily";
          port = ports.servicePorts.loki;
          vHost = "loki.${config.myDns.networkMap.name}";
        };

        # ============================================
        # Networking
        # ============================================
        traefik = {
          hostName = "emily";
          port = ports.servicePorts.traefik;
          vHost = "traefik.${config.myDns.networkMap.name}";
        };

        # ============================================
        # RSS & News
        # ============================================
        freshrss = {
          hostName = "emily";
          port = ports.containerPorts.freshrss;
          vHost = "freshrss.${config.myDns.networkMap.name}";
        };

        # ============================================
        # Security
        # ============================================
        vault = {
          hostName = "runner";
          port = ports.containerPorts.vault;
          vHost = "vault.${config.myDns.networkMap.name}";
        };

        # ============================================
        # Storage
        # ============================================
        garage-webui = {
          hostName = "bellamy";
          port = ports.servicePorts.garage-webui;
          vHost = "s3-web.${config.myDns.networkMap.name}";
        };

        # ============================================
        # Version Control
        # ============================================
        forgejo = {
          hostName = "runner";
          port = ports.servicePorts.forgejo;
          vHost = "runner.${config.myDns.networkMap.name}";
        };

        # ============================================
        # Web Applications
        # ============================================
        fossflow = {
          hostName = "emily";
          port = ports.containerPorts.fossflow;
          vHost = "fossflow.${config.myDns.networkMap.name}";
        };
        zerobyte = {
          hostName = "emily";
          port = ports.containerPorts.zerobyte;
          vHost = "zerobyte.${config.myDns.networkMap.name}";
        };
      };
    };
  };
}
