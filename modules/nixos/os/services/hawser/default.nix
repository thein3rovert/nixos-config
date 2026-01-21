{
  config,
  lib,
  ...
}:
let

  if-hawser-enable = lib.mkIf config.nixosSetup.services.hawser.enable;
  # create-linkding-containter = virtualisation.oci-containers."linkding";
  imageName = "ghcr.io/finsys/hawser";
  imageTag = "latest";
  port = 2376;

  dataVolume = "hawser_data:/data/stacks";
  socketVolume = "/run/podman/podman.sock:/var/run/docker.sock";
in
{
  options.nixosSetup.services.hawser = {
    enable = lib.mkEnableOption "Remote Docker agent for Dockhand";
  };

  config = if-hawser-enable {
    virtualisation.oci-containers.containers.hawser = {
      image = "${imageName}:${imageTag}";
      ports = [ "${toString port}:2376" ];
      volumes = [
        dataVolume
        socketVolume
      ];
      environment = {
        TOKEN = "hgmFGT9LpRYArXBHh510pA20rBEnT5hu";
      };
    };
  };

}
