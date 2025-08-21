{
  config,
  lib,
  ...
}:
let
  cfg = config.coreModules.services;
in
{
  options.coreModules.services.enable = lib.mkEnableOption "Enable my core services modules";

  # Can this config be any variable
  config = lib.mkIf cfg.enable {
    # TODO: Move to respective modules later

    services.gnome.gnome-keyring.enable = true;
    services.gnome.gnome-remote-desktop.enable = true;
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
    services.flatpak.enable = true;
    services.pulseaudio.enable = false;

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
  };

}
