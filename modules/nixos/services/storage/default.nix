{ lib, ... }:
{
  imports = [
    ./minio
    ./garage
    ./garage-webui
  ];
}
