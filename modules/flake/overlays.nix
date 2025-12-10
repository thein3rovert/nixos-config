{ self, ... }:
{
  flake.overlays = {
    # Define the default overlay
    default =
      # Standard overlay function signature:
      # - _final: the final (fully built) package set
      # - prev: the previous package set before applying this overlay
      _final: prev:

      let
        # Import a secondary nixpkgs source from your flake inputs
        # (e.g., a newer or smaller "unstable" channel)
        nixos-unstable-small = import self.inputs.nixpkgs-unstable-small {
          config.allowUnfree = true;
          # Reuse the same system architecture as the current package set
          inherit (prev) system;
        };
      in
      {
        firefox-unstable = nixos-unstable-small.firefox;
        # Pull (inherit) specific packages from the nixos-unstable-small channel
        # and make them available in the current package set.
        # This effectively overrides your current versions of these packages
        # with newer ones from nixos-unstable-small.
        inherit (nixos-unstable-small)
          firefox
          thunderbird
          # zed-editor
          ;
      };
  };
}
