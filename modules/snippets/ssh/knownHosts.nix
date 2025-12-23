{
  config,
  lib,
  self,
  ...
}:
{
  options.snippets.ssh.knownHosts = lib.mkOption {
    type = lib.types.attrs;
    description = "All ssh known hosts.";

    default = {
      bellamy = {
        hostNames = [
          "bellamy"
          "bellamy.local"
          "bellamy.${config.snippets.tailnet.name}"
        ];
        publicKeyFile = "${self.inputs.secrets}/publicKeys/thein3rovert_bellamy.pub";
      };
      wellsjaha = {
        hostNames = [
          "wellsjaha"
          "wellsjaha.local"
          "wellsjaha.${config.snippets.tailnet.name}"
        ];
        publicKeyFile = "${self.inputs.secrets}/publicKeys/thein3rovert_wellsjaha.pub";
      };
      finn = {
        hostNames = [
          "finn"
          "finn.local"
          "finn.${config.snippets.tailnet.name}"
        ];
        publicKeyFile = "${self.inputs.secrets}/publicKeys/thein3rovert_finn.pub";
      };
      lexa = {
        hostNames = [
          "lexa"
          "lexa.local"
          "lexa.${config.snippets.tailnet.name}"
        ];
        publicKeyFile = "${self.inputs.secrets}/publicKeys/thein3rovert_lexa.pub";
      };
      nixos = {
        hostNames = [
          "nixos"
          "nixos.local"
          "nixos.${config.snippets.tailnet.name}"
        ];
        publicKeyFile = "${self.inputs.secrets}/publicKeys/thein3rovert_nixos.pub";
      };
    };
  };
}
