let
  username = "introvert";
  hostname = "nixos";
  userHome = "/home/${username}";
  flakeDirectory = "${userHome}/my-nix-flake";

  # Networking for future uses
  proxy = true;
  socks = "";
  http = "";

in
{
  username = username;
  hostname = hostname;
  userHome = "${userHome}";
  flakeDir = "${flakeDirectory}";

  #GIT RELATED
  gitUsername = "thein3rovert";
  gitEmail = "danielolabi@gmail.com";

  browser = "zen";
  terminal = "kitty"; # This sets the terminal that is used by the hyprland terminal keybinding

  # System Settings
  clock24h = false;
  theLocale = "en_GB.UTF-8";
  theKBDLayout = "uk";
  theSecondKBDLayout = "de";
  theKBDVariant = "";
  theLCVariables = "en_GB.UTF-8";
  theTimezone = "Europe/London";
  sdl-videodriver = "x11";
  theShell = "zsh"; # Possible options: bash, zsh
  theKernel = "default"; # Possible options: default, latest, lqx, xanmod, zen
  cpuType = "intel";
  gpuType = "intel";

  #Proxy Settings - Not using yet, have to figure out my proxy
  useProxy = proxy;
  socksProxy = if proxy == true then "socks5://127.0.0.1:${socks}" else "";
  httpProxy = if proxy == true then "http://127.0.0.1:${http}" else "";

  #Firewall Allowed TCP Ports
  useFirewall = true;
  firewallPorts = [
    1090
    5000
    5050
    5900
    9000
  ];

  # Enable / Setup NFS - Dont have NFS yet
  #    nfs = false;
  #    nfsMountPoint = "/mnt/nas";
  #    nfsDevice = "nas:/volume1/nas";

  #  NTP & HWClock Settings
  ntp = true;
  localHWClock = false;

  #   Enable Printer & Scanner Support
  printer = true;

  # Enable Flatpak & Larger Programs
  distrobox = false;
  flatpak = false;
  kdenlive = false;

  # Enable Support For
  # Logitech Devices
  logitech = true;

  # Enable Terminals
  # If You Disable All You Get Kitty
  wezterm = false;
  alacritty = false;
  kitty = true;

  # Enable Python & PyCharm
  python = true;

}
