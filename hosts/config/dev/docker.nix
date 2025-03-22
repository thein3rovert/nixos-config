{ config, pkgs, ... }:
{
  virtualisation.docker = {
    enable = true;
    #    storageDriver = "overlay2";  # Optional, customize as needed
    #    extraOptions = "--experimental";  # Optional, customize as needed
    #    defaultBridge = {
    #     enable = true;
    #    subnet = "172.18.0.0/16";
    #    };
  };

  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  # Add any users you want to give Docker access to
  users.users.thein3rovert.extraGroups = [ "docker" ];
}

