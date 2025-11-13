{
  pkgs,
  lib,
  config,
  ...
}:
let

  if-mysql-enable = lib.mkIf config.nixosSetup.services.mysql.enable;
in
{

  options.nixosSetup.services.mysql = {
    enable = lib.mkEnableOption "mysql Database";
  };

  config = if-mysql-enable {
    services.mysql = {
      enable = true;
      package = pkgs.mysql84;
      ensureDatabases = [
        "thein3rovert"
        "n8n"
      ];
      initialScript = pkgs.writeText "initial-script.sql" ''
        CREATE USER 'thein3rovert'@'10.89.%' IDENTIFIED BY 'thein3rovert';
        GRANT ALL PRIVILEGES ON thein3rovert.* TO 'thein3rovert'@'10.89.%';

        CREATE USER 'n8n'@'10.89.%' IDENTIFIED BY 'n8n';
        GRANT ALL PRIVILEGES ON n8n.* TO 'n8n'@'10.89.%'; '';
    };
    services.mysqlBackup = {
      enable = true;
      calendar = "03:00:00";
      databases = [
        "thein3rovert"
        "n8n"
      ];
    };
    networking.firewall = {
      # Podman network and localnetwork
      extraCommands = ''
        iptables -A INPUT -p tcp -s 127.0.0.1 --dport 3306 -j ACCEPT
        iptables -A INPUT -p tcp -s 10.89.0.0/24 --dport 3306 -j ACCEPT
      '';
    };
  };
}
