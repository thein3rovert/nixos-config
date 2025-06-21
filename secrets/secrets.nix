let
  nixos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL60abQ+uQoKBdYylRMzMbqSBKMeCj0cU9hJMT7O0gn6"; # Main system
  vps-het-1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF5A5HhG7exq5I0uQv8/BJHPsGbV4u6lqLaXeVaUaJwW";
  thein3rovert = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGKcMZafP6nbYGk5MKxll1GkI/JKesULVmHL0ragX0Qe";
  systems = [
    nixos
    vps-het-1
  ];
  users = [ thein3rovert ];
in
{
  "secret2.age".publicKeys = systems ++ users;
  "linkding-env.age".publicKeys = systems ++ users;
  "freshrss-env.age".publicKeys = systems ++ users;
}

# let
#   # === SYSTEM ===
#   nixos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL60abQ+uQoKBdYylRMzMbqSBKMeCj0cU9hJMT7O0gn6"; # Main system
#   vps-het-1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF5A5HhG7exq5I0uQv8/BJHPsGbV4u6lqLaXeVaUaJwW";
#   # === USERS ===
#   thein3rovert = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGKcMZafP6nbYGk5MKxll1GkI/JKesULVmHL0ragX0Qe";
#   thein3rovert-cloud = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKpJqLA+ZOmc0Rc+gz4+p5O6xJhx/PwZfO7jy6UuK2rz danielolaibi@gmail.com";
#   systems = [
#     nixos
#   ];
#
#   users = [
#     thein3rovert
#   ];
# in
# {
#   "secret1.age".publicKeys = systems ++ users;
#   # "linkding-env.age".publicKeys = systems ++ users;
#   # "freshrss-env.age".publicKeys = systems ++ users;
# }
