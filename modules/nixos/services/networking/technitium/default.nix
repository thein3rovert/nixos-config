{ config, lib, ... }:
let
  cfg = config.nixosSetup.services.technitium;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    concatStringsSep
    optionalAttrs
    ;

  image = "docker.io/technitium/dns-server:15.1.0";

  # Technitium binds directly to these ports via host networking
  dnsPort = config.homelab.servicePorts.technitium;
  webUiPort = config.homelab.containerPorts.technitium;

  # Persistent host paths (mounted into the container)
  configDir = "/var/lib/technitium"; # zones + settings -> /etc/dns
  logDir = "/var/log/technitium/dns"; # query/app logs

  # Technitium expects semicolon-separated forwarders
  forwarders = concatStringsSep ";" cfg.forwarders;
in
{
  options.nixosSetup.services.technitium = {
    enable = mkEnableOption "Technitium DNS server";

    domain = mkOption {
      type = types.str;
      default = config.homelab.domain.local;
      description = "Primary domain served by Technitium";
    };

    forwarders = mkOption {
      type = types.listOf types.str;
      default = [ "1.1.1.1" "8.8.8.8" ];
      description = "Upstream forwarders (joined with ';' for Technitium)";
    };

    recursion = mkOption {
      type = types.enum [ "allow" "deny" "allowOnlyForPrivateNetworks" "useSpecifiedNetworks" ];
      default = "allowOnlyForPrivateNetworks";
      description = "Recursion policy for the resolver";
    };

    enableBlocking = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Technitium's built-in ad/malware blocking";
    };

    enableDnsOverHttp = mkOption {
      type = types.bool;
      default = false;
      description = "Enable DNS-over-HTTP on port 80 (DoH is always on 443)";
    };
  };

  config = mkIf cfg.enable {
    # ---- Persistent directories ----
    systemd.tmpfiles.rules = [
      "d ${configDir} 0755 root root -"
      "d ${logDir} 0755 root root -"
    ];

    # ---- Container (host networking so it can bind :53 + DoH/DoT) ----
    virtualisation.oci-containers.containers.technitium = {
      image = image;
      autoStart = true;
      extraOptions = [ "--network=host" ];
      environment =
        {
          DNS_SERVER_DOMAIN = cfg.domain;
          DNS_SERVER_LOG_FOLDER_PATH = "/var/log/technitium/dns";
          DNS_SERVER_LOG_USING_LOCAL_TIME = "true";
          DNS_SERVER_RECURSION = cfg.recursion;
          DNS_SERVER_FORWARDERS = forwarders;
          DNS_SERVER_FORWARDER_PROTOCOL = "Udp";
        }
        // optionalAttrs cfg.enableBlocking { DNS_SERVER_ENABLE_BLOCKING = "true"; }
        // optionalAttrs cfg.enableDnsOverHttp { DNS_SERVER_OPTIONAL_PROTOCOL_DNS_OVER_HTTP = "true"; };

      # Admin password injected via agenix (see hosts/nixos/secrets.nix)
      environmentFiles = [ config.age.secrets.technitium-env.path ];

      volumes = [
        "${configDir}:/etc/dns"
        "${logDir}:/var/log/technitium/dns"
      ];
    };

    # Widen ephemeral port range (recommended for a busy resolver)
    boot.kernel.sysctl."net.ipv4.ip_local_port_range" = "1024 65535";

    # ---- Firewall ----
    networking.firewall = {
      allowedTCPPorts = [
        dnsPort # 53 - DNS over TCP
        webUiPort # 5380 - admin dashboard
        443 # DNS-over-HTTPS
        853 # DNS-over-TLS
      ];
      allowedUDPPorts = [
        dnsPort # 53 - DNS over UDP
        853 # DNS-over-QUIC
      ];
    };
  };
}
