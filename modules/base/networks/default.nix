{
  config,
  ...
}:
let
  homelab = config.homelab;
in
{
  homelab = {
    #   TODO: Confirm if i need to add the types

    dns = [ ];
    vm-dns = [
      "1.1.1.1"
      "8.8.8.8"
    ];
    con-dns = [ ];
  };
}
