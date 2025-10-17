{ config, lib, ... }:
let
  inherit (lib)
    mkIf
    mkEnableOption
    ;
  if-nginx-enable = mkIf config.nixosSetup.services.nginx.enable;
in
{
  options.nixosSetup.services.nginx = {
    enable = mkEnableOption "Nginx Server";
  };

  config = if-nginx-enable {
    services.nginx = {
      enable = true;

      virtualHosts."localhost" = {
        root = "/var/www/localhost";

        # TODO: Create module options
        listen = [
          {
            addr = "0.0.0.0";
            port = 80;
          }
          # Create addr for 443
          # {
          #   addr = "10.10.10.6";
          #   port = 443;
          #   ssl = true;
          # }
        ];

        locations."/" = {
          index = "index.html";
        };
      };
    };

    # Simple HTML page for testing
    systemd.tmpfiles.rules = [
      "d /var/www/localhost 0755 root root -"
      # Copy created file to /localhost at boot from nix store
      # `C` copy file on boot if its missing
      # `f` create file on boot
      # `sudo systemd-tmpfiles --create` create manually
      # Systemd tmpfile format `<type> <path> <mode> <uid> <gid> <age> <argument>`
      # `C!` force copy file from source path (Nix Store)
      "C! /var/www/localhost/index.html 0644 root root - ${builtins.toFile "index.html" ''
        <!DOCTYPE html>
        <html>
          <head><title> Hello from thein3rovert</title></head>
          <body>
            <h1> Hello from the in3rovert Nginx on Nixos!</h1>
            <p> Served from a nixos declarative config 😎 </p>
          </body>
          </html>
      ''}"
    ];
  };
}
