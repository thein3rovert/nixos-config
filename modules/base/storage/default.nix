{
  config,
  ...
}:
let
  homelab = config.homelab;
in
{
  homelab = {
    # Container storage configuration
    containerStorage = {
      traefik = {
        path = "/var/lib/containers/traefik";
        owner = homelab.user;
        group = homelab.group;
        permissions = "755";
      };

      linkding = {
        path = "/var/lib/containers/linkding";
        owner = homelab.user;
        group = homelab.group;
        permissions = "755";
      };

      # Add more container storage paths as needed
      nginx = {
        path = "/var/lib/containers/nginx";
        owner = homelab.user;
        group = homelab.group;
        permissions = "755";
      };
    };

    # Services storage configuration
    servicesStorage = {
      adguard = {
        path = "/var/lib/adguardhome";
        owner = homelab.user;
        group = homelab.group;
        permissions = "755";
      };

      ssh = {
        path = "/var/lib/ssh";
        owner = homelab.user;
        group = homelab.group;
        permissions = "700";
      };

      # Custom application storage
      ipam = {
        path = "/var/lib/ipam";
        owner = homelab.user;
        group = homelab.group;
        permissions = "755";
      };

      api = {
        path = "/var/lib/api";
        owner = homelab.user;
        group = homelab.group;
        permissions = "755";
      };

      # Common shared storage locations
      media = {
        path = "/srv/media";
        owner = homelab.user;
        group = homelab.group;
        permissions = "755";
      };

      backups = {
        path = "/srv/backups";
        owner = homelab.user;
        group = homelab.group;
        permissions = "750";
      };

      config = {
        path = "/srv/config";
        owner = homelab.user;
        group = homelab.group;
        permissions = "755";
      };

      logs = {
        path = "/var/log/homelab";
        owner = homelab.user;
        group = homelab.group;
        permissions = "755";
      };
    };
  };
}
