let

  # === SYSTEM ===
  nixos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL60abQ+uQoKBdYylRMzMbqSBKMeCj0cU9hJMT7O0gn6"; # Main system

  # === USERS ===
  thein3rovert = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGKcMZafP6nbYGk5MKxll1GkI/JKesULVmHL0ragX0Qe";

  systems = [ nixos ];
  users = [ thein3rovert ];
in
{
  "secret1.age".publicKeys = systems ++ users;
}
