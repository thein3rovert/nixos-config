{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.nixosSetup.programs.docker.enable = lib.mkEnableOption "docker container runtime";
  config = lib.mkIf config.nixosSetup.programs.docker.enable {
    virtualisation.docker = {
      enable = true;
      autoPrune.enable = true;
    };
    virtualisation.oci-containers.backend = "docker";
    virtualisation.docker.logDriver = "json-file";
    users.groups.docker = { }; # Create docker group
  };
}
