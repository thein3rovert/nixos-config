{
  pkgs,
  config,
  lib,
  ...
}:

{
  security.rtkit.enable = true;
  # Allow passwordless actions
  security.sudo.extraRules = [
    {
      users = [ "thein3rovert" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  #  security.pam.services.hyprlock = {};
  #  security.pam.services.swaylock = {
  #    text = ''
  #      auth include login
  #   '';
  #  };

  # # Ensure the group exists
  # users.groups.wireshark = { };
  #
  # security.wrappers.dumpcap = {
  #   owner = "root";
  #   group = "wireshark";
  #   capabilities = "cap_net_raw,cap_net_admin+eip";
  #   source = "${pkgs.wireshark}/bin/dumpcap";
  # };
  #
  # users.users.introvert.extraGroups = [ "wireshark" ];
  #
  #

}
