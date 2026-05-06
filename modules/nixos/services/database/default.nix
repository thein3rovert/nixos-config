{ lib, ... }:
{
  imports = [
    ./postgres
    ./myslql
    ./pgadmin
    ./dbpro-studio
  ];
}
