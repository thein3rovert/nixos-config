{
  lib,
  config,
  pkgs,
  ...
}:
let
  # freshrssPassword = "/etc/nixos/freshrss-password.txt";
  freshrssPassword = pkgs.writeText "password" "secret";

  # freshrssPassword = "/home/thein3rovert/Documents/secrets/freshrss-password.txt";
in
{
  users.users.freshrss = {
    isSystemUser = true;
    home = "/var/lib/freshrss";
  };

  services.freshrss = {
    enable = true;
    user = "freshrss";
    baseUrl = "http://localhost/freshrss";
    authType = "form";
    # passwordFile = freshrssPassward;

    passwordFile = freshrssPassword;
  };
}
