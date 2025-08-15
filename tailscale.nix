{
  # General ACL rules for network traffic
  acls = [
    {
      action = "accept"; # Allow the traffic
      dst = [ "*:*" ]; # Destination: any host, any port
      src = [ "*" ]; # Source: any device/user in the Tailnet
      # This essentially allows unrestricted network access between all nodes
    }
  ];

  # SSH-specific rules for Tailscale SSH feature
  ssh = [
    {
      action = "accept"; # Explicitly allow SSH access if policy matches
      dst = [ "autogroup:self" ]; # Destination device: only the same device you belong to
      src = [ "autogroup:member" ]; # Source device: any member of the Tailnet
      # This means you can SSH only into your own device, not others

      users = [
        "autogroup:nonroot" # Allow non-root users in the Tailnet
        "root" # Allow root user as well
      ];
      # Only these user accounts can login over Tailscale SSH on this device
    }
  ];
}
