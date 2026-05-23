{ lib, ... }:
{
  imports = [
    ./minio
    ./garage
    ./garage-webui
    ./fileshare
    ./syncthing
    ./say-cheese
  ];
}
