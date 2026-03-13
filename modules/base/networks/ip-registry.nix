{ lib, config, ... }:
let
  inherit (lib) mkOption types;
  networkMap = config.myDns.networkMap.localNetworkMap;
  prodMap = config.snippets.thein3rovert.networkMap;
  hosts = config.homelab.ipAddresses;
in
{
  options.homelab.ipRegistry = mkOption {
    type = types.attrsOf (
      types.submodule {
        options = {
          ip = mkOption {
            type = types.str;
            description = "IP address";
            default = "127.0.0.1";
          };
          port = mkOption {
            type = types.either types.int types.str;
            description = "Port number";
          };
          url = mkOption {
            type = types.str;
            description = "Full URL (auto-generated)";
            readOnly = true;
          };
        };
      }
    );
    default = { };
    description = "Centralized IP registry for services";
  };

  config.homelab.ipRegistry = {
    # Local Services (running on emily - using localhost)
    zerobyte = {
      ip = hosts.localhost.ip;
      port = networkMap.zerobyte.port;
      url = "http://${config.homelab.ipRegistry.zerobyte.ip}:${toString config.homelab.ipRegistry.zerobyte.port}/";
    };
    grafana = {
      ip = hosts.localhost.ip;
      port = networkMap.grafana.port;
      url = "http://${config.homelab.ipRegistry.grafana.ip}:${toString config.homelab.ipRegistry.grafana.port}/";
    };
    loki = {
      ip = hosts.localhost.ip;
      port = networkMap.loki.port;
      url = "http://${config.homelab.ipRegistry.loki.ip}:${toString config.homelab.ipRegistry.loki.port}/";
    };

    # Container LXC Services
    ad-guard = {
      ip = hosts.finn.ip;
      port = networkMap.ad-guard.port;
      url = "http://${config.homelab.ipRegistry.ad-guard.ip}:${toString config.homelab.ipRegistry.ad-guard.port}/";
    };
    n8n = {
      ip = hosts.emily.ip;
      port = networkMap.n8n.port;
      url = "http://${config.homelab.ipRegistry.n8n.ip}:${toString config.homelab.ipRegistry.n8n.port}/";
    };
    fossflow = {
      ip = hosts.emily.ip;
      port = networkMap.fossflow.port;
      url = "http://${config.homelab.ipRegistry.fossflow.ip}:${toString config.homelab.ipRegistry.fossflow.port}/";
    };
    dockhand = {
      ip = hosts.emily.ip;
      port = 3000;
      url = "http://${config.homelab.ipRegistry.dockhand.ip}:${toString config.homelab.ipRegistry.dockhand.port}/";
    };
    incus = {
      ip = hosts.emily.ip;
      port = networkMap.incus.port;
      url = "${config.homelab.ipRegistry.incus.ip}:${toString config.homelab.ipRegistry.incus.port}";
    };

    # VM Services
    linkding = {
      ip = "10.20.0.1";
      port = networkMap.linkding.port;
      url = "http://${config.homelab.ipRegistry.linkding.ip}:${toString config.homelab.ipRegistry.linkding.port}/";
    };

    # Tailscale Services
    vault = {
      ip = hosts.emily.tailscaleIp;
      port = networkMap.vault.port;
      url = "http://${config.homelab.ipRegistry.vault.ip}:${toString config.homelab.ipRegistry.vault.port}/";
    };
    garage-webui = {
      ip = hosts.bellamy.tailscaleIp;
      port = 3909;
      url = "http://${config.homelab.ipRegistry.garage-webui.ip}:${toString config.homelab.ipRegistry.garage-webui.port}/";
    };

    # =========================
    #       PRODUCTION (VPS)
    # =========================
    # Production VPS Services (localhost on bellamy VPS)
    garage = {
      ip = "localhost";
      port = prodMap.garage-api.port;
      url = "http://${config.homelab.ipRegistry.garage.ip}:${toString config.homelab.ipRegistry.garage.port}/";
    };
    memos = {
      ip = "localhost";
      port = 5230;
      url = "http://${config.homelab.ipRegistry.memos.ip}:${toString config.homelab.ipRegistry.memos.port}/";
    };
    forgejo = {
      ip = "localhost";
      port = prodMap.forgejo.port;
      url = "http://${config.homelab.ipRegistry.forgejo.ip}:${toString config.homelab.ipRegistry.forgejo.port}/";
    };
    blog = {
      ip = "localhost";
      port = 8084;
      url = "http://${config.homelab.ipRegistry.blog.ip}:${toString config.homelab.ipRegistry.blog.port}/";
    };
  };
}
