{ lib, config, ... }:
let
  cfg = config.homelab;
  baseDomain = cfg.domain.prod;
in
{
  # ============================================
  # Production Network Map Options
  # ============================================
  options.snippets.thein3rovert.networkMap = lib.mkOption {
    type = lib.types.attrs;
    description = "Hostnames, ports, and vHosts for thein3rovert.dev services.";
    default = {
      # ============================================
      # Automation
      # ============================================
      n8n = {
        hostName = "bellamy";
        port = cfg.servicePorts.n8n;
        vHost = "n8n.${baseDomain}";
      };

      # ============================================
      # Bookmarking & Links
      # ============================================
      linkding = {
        hostName = "bellamy";
        port = cfg.containerPorts.linkding;
        vHost = "linkding.${baseDomain}";
      };

      # ============================================
      # Monitoring
      # ============================================
      uptime-kuma = {
        hostName = "bellamy";
        port = cfg.containerPorts.uptime-kuma;
        vHost = "uptime-kuma.${baseDomain}";
      };

      # ============================================
      # Networking
      # ============================================
      traefik = {
        hostName = "bellamy";
        port = cfg.servicePorts.traefik;
        vHost = "traefik.${baseDomain}";
      };

      # ============================================
      # RSS & News
      # ============================================
      freshrss = {
        hostName = "bellamy";
        port = cfg.containerPorts.freshrss;
        vHost = "freshrss.${baseDomain}";
      };
      jotty = {
        hostName = "bellamy";
        port = cfg.containerPorts.jotty;
        vHost = "jotty.${baseDomain}";
      };

      # ============================================
      # Storage
      # ============================================
      s3 = {
        hostName = "bellamy";
        port = cfg.servicePorts.minio;
        vHost = [
          "minio-console.${baseDomain}"
          "minio.${baseDomain}"
        ];
      };
      garage-api = {
        hostName = "bellamy";
        port = cfg.servicePorts.garage-api;
        vHost = "s3.${baseDomain}";
      };

      # ============================================
      # Version Control
      # ============================================
      forgejo = {
        hostName = "bellamy";
        port = cfg.servicePorts.forgejo;
        sshVHost = "ssh.${baseDomain}";
        vHost = "code.${baseDomain}";
      };

      # ============================================
      # Web Applications
      # ============================================
      memos = {
        hostName = "bellamy";
        port = cfg.containerPorts.memos;
        vHost = "memos.${baseDomain}";
      };
      blog = {
        hostName = "bellamy";
        port = cfg.containerPorts.blog;
        vHost = "blog.${baseDomain}";
      };
      glance = {
        hostName = "bellamy";
        port = cfg.containerPorts.glance;
        vHost = "glance.${baseDomain}";
      };
    };
  };
}
