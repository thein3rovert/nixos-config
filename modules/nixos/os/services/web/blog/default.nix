{
  config,
  lib,
  ...
}:
let

  if-blog-enable = lib.mkIf config.nixosSetup.services.blog.enable;
  imageName = "theintrovert/blog.thein3rovert.dev";
  imageTag = "latest";
  port = 8084;
in
{
  options.nixosSetup.services.blog = {
    enable = lib.mkEnableOption "My personal Blog";
  };

  config = if-blog-enable {
    virtualisation.oci-containers.containers.blog = {
      image = "${imageName}:${imageTag}";
      ports = [ "${toString port}:80" ];
    };
  };
}
