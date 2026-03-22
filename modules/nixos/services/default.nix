{ lib, ... }:
{
  imports = [
    ./web
    ./media
    ./networking
    ./monitoring
    ./storage
    ./database
    ./automation
    ./cicd
  ];
}
