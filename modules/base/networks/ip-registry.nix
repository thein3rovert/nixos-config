{ lib, config, ... }:
let
  inherit (lib) mkOption types;
  networkMap = config.myDns.networkMap.localNetworkMap;
in
{
  options.homelab.ipRegistry = mkOption {
    type = types.attrsOf (
      types.submodule {
        options = {
          ip = mkOption {
            type = types.str;
            description = "IP address";
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
    # Local Services (127.0.0.1 / localhost)
    zerobyte = {
      ip = "127.0.0.1";
      port = networkMap.zerobyte.port;
      url = "http://${config.homelab.ipRegistry.zerobyte.ip}:${toString config.homelab.ipRegistry.zerobyte.port}/";
    };
    grafana = {
      ip = "127.0.0.1";
      port = networkMap.grafana.port;
      url = "http://${config.homelab.ipRegistry.grafana.ip}:${toString config.homelab.ipRegistry.grafana.port}/";
    };
    loki = {
      ip = "127.0.0.1";
      port = networkMap.loki.port;
      url = "http://${config.homelab.ipRegistry.loki.ip}:${toString config.homelab.ipRegistry.loki.port}/";
    };

    # Container LXC Services
    ad-guard = {
      ip = "10.10.10.10";
      port = networkMap.ad-guard.port;
      url = "http://${config.homelab.ipRegistry.ad-guard.ip}:${toString config.homelab.ipRegistry.ad-guard.port}/";
    };
    n8n = {
      ip = "10.10.10.12";
      port = networkMap.n8n.port;
      url = "http://${config.homelab.ipRegistry.n8n.ip}:${toString config.homelab.ipRegistry.n8n.port}/";
    };
    fossflow = {
      ip = "10.10.10.12";
      port = networkMap.fossflow.port;
      url = "http://${config.homelab.ipRegistry.fossflow.ip}:${toString config.homelab.ipRegistry.fossflow.port}/";
    };
    dockhand = {
      ip = "10.10.10.12";
      port = 3000;
      url = "http://${config.homelab.ipRegistry.dockhand.ip}:${toString config.homelab.ipRegistry.dockhand.port}/";
    };
    incus = {
      ip = "10.10.10.12";
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
      ip = "100.105.217.77";
      port = networkMap.vault.port;
      url = "http://${config.homelab.ipRegistry.vault.ip}:${toString config.homelab.ipRegistry.vault.port}/";
    };
    garage-webui = {
      ip = "100.105.187.63";
      port = 3909;
      url = "http://${config.homelab.ipRegistry.garage-webui.ip}:${toString config.homelab.ipRegistry.garage-webui.port}/";
    };
  };
}
