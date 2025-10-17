{ lib, ... }:
{
  # === Custom options for user management under 'myUsers'
  options.myUsers =
    let
      # === NOTE ===
      # mkUser is a reusuable function to define per-user config block
      mkUser = user: {
        enable = lib.mkEnableOption "${user}.";

        # === Option to specify the user's hashed password ===
        password = lib.mkOption {
          default = null;
          description = "Hashed password for ${user}.";
          type = lib.types.nullOr lib.types.str;
        };
      };

    in
    {
      # === The default user group for all users ===
      defaultGroups = lib.mkOption {
        description = "Default groups for desktop users.";
        default = [
          "docker"
          "libvirtd"
          "networkmanager"
          "video"
          "wheel"
        ];
      };

      # ===Option to enable/disable root user configuration (enabled by default) ===
      root.enable = lib.mkEnableOption "root user configuration." // {
        default = true;
      };

      # === Define user options for 'thein3rovert' and 'newUser' using the mkUser function ===
      thein3rovert = mkUser "thein3rovert";
      # === If want to create new user, rename below ===
      # newUser = mkUser "newUser";
    };
}
