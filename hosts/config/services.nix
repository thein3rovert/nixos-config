#   ___  ____  ___  __  __  ____  ____  ____  _  _
#  / __)( ___)/ __)(  )(  )(  _ \(_  _)(_  _)( \/ )
#  \__ \ )__)( (__  )(__)(  )   / _)(_   )(   \  /
#  (___/(____)\___)(______)(_)\_)(____) (__)  (__)

{
  pkgs,
  config,
  lib,
  ...
}:

{

  # List services that you want to enable:
  #  services.openssh.enable = true;
  #  services.fstrim.enable = true;
  #  services.vnstat.enable = true;
  #  services.gvfs.enable = true;
  #  services.tumbler.enable = true;
  #  services.upower.enable = true;
  #  services.thermald.enable = false;
  #  services.hypridle.enable = true;
  #  services.power-profiles-daemon.enable = true;  # Using TLP now - see battery.nix

  services.gnome.gnome-keyring.enable = true; # Not in main config
  services.gnome.gnome-remote-desktop.enable = true; # Not in main config
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    audio.enable = true;
    pulse.enable = true;
    #    socketActivation = true;
    jack.enable = true;
    wireplumber.enable = true;
  };
  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
    allowSFTP = true;
  };
  # List services that you want to enable:
  services.openssh.settings.PasswordAuthentication = true;
  services.openssh.settings.KbdInteractiveAuthentication = false;
  services.openssh.settings.X11Forwarding = true;
  services.openssh.settings.X11DisplayOffset = 10;
  services.blueman.enable = true;
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.xserver.updateDbusEnvironment = true;
  services.flatpak.enable = true; # Need to update some new packages using flatpack e.g VSCODE
  services.pulseaudio.enable = false; # This has been renamed from hardware to services so i moved it to services

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "gb";
    xkb.variant = "";
  };

    # Enable touchpad support (enabled default in most desktopManager).
   services.xserver.libinput.enable = true;


  #Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  #  services.resolved = {
  #   enable = true;
  #    dnssec = "true";
  #    dnsovertls = "true";
  #    fallbackDns = [ "165.22.52.204" ];
  #    extraConfig = ''
  #      Domains=~.
  #      DNS= 1.1.1.1:853 1.0.0.1:853 2606:4700:4700::1111 2606:4700:4700::1001###

  #      [Proxy]
  #      Proxy=socks5://127.0.0.1:1080
  #    '';
  #  };

}