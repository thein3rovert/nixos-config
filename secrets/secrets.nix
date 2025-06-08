let
  nixos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL60abQ+uQoKBdYylRMzMbqSBKMeCj0cU9hJMT7O0gn6"; # Main system
in
{
  "secret1.age".publicKeys = [ nixos ];
}
