{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    ;
  createOption = mkOption;

  # Types
  string = types.str;
in
{
  options.diskoDrive.installDrive = createOption {
    discription = "VDA disk to install Nixos to.";
    default = "/dev/vda";
    type = string;
  };

  config = {
    assertions = [
      {
        assertion = config.diskoDrive.installDrive != "";
        message = "config.diskoDrive.installDrive cannot be empty.";
      }
    ];

  };
}
