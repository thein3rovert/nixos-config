# Reference: Host "fallarbor" aly
{
  config,
  self,
  ...
}:
{
  imports = [

  ];

  environment.variables.GDK_SCALE = "1.25";
  networking.hostName = "wellsjaha";
  system.stateVersion = "25.05";
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # Configure console keymap
  console.keyMap = "uk";

  # === Password using "mkpasswd --method=yescrypt" ===
  myUsers = {
    thein3rovert = {
      enable = true;
      password = "$y$j9T$ijOefXV1SG7tcj6ALYFlW1$eROUM..nWeygQYzH3gD75IRwCiAf40NAx6R2OwUVIt9";
    };

    # newUser = {
    #   enable = true;
    #   password = "$y$j9T$OXQYhj4IWjRJWWYsSwcqf.$lCcdq9S7m0EAdej9KMHWj9flH8K2pUb2gitNhLTlLG/";
    # };
  };
}
