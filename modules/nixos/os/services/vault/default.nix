{
  config,
  lib,
  ...
}:
let
  cfg = config.nixosSetup.services.vault;
in
{
  options.nixosSetup.services.vault.enable = lib.mkEnableOption "Hasicorp Vault for terraform";
  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers.vault = {
      image = "hashicorp/vault";
      ports = [
        "8200:8200"
        "8201:8201"
      ];
      volumes = [
        "/var/lib/vault/config:/vault/config"
        "/var/lib/vault/data:/vault/data"
      ];
      cmd = [
        "vault"
        "server"
        "-config=/vault/config/vault.hcl"
      ];
      extraOptions = [ "--cap-add=IPC_LOCK" ];
    };
    systemd.tmpfiles.rules = [
      "d /var/lib/vault/config 0755 root root -"
      "d /var/lib/vault/data 0755 root root -"
    ];
  };
}
