let
  # === SYSTEMS ===
  nixos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL60abQ+uQoKBdYylRMzMbqSBKMeCj0cU9hJMT7O0gn6"; # Main system
  vps-het-1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFAMePGuz68j21bIQC8KospK3bs9xvTocngpY6h035Gh"; # vps system
  wellsjaha = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKNqDp0mblc7I7Prz/cFYf20IeMq1zvH4WlJbhp4W0h9";
  # === USERS ===
  thein3rovert-cloud = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKU41SZ5MS0hOVb79aCu7E8w7+i6rbMr7JpSXcEXbti7"; # vps user
  thein3rovert = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGKcMZafP6nbYGk5MKxll1GkI/JKesULVmHL0ragX0Qe"; # Main user

  systems = [
    nixos
    vps-het-1
    wellsjaha
  ];
  users = [
    thein3rovert
    thein3rovert-cloud
  ];
in
{
  "secret2.age".publicKeys = systems ++ users;
  "linkding-env.age".publicKeys = systems ++ users;
  "freshrss-env.age".publicKeys = systems ++ users;
  "traefik-env.age".publicKeys = systems ++ users;
  "minio-env.age".publicKeys = systems ++ users;
  "tailscale-env.age".publicKeys = systems ++ users;

  # Tailscale for wellsjaha
  "tailscale-env-01.age".publicKeys = systems ++ users;
}
