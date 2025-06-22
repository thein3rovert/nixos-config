{
  virtualisation.oci-containers.containers."slash" = {
    image = "docker.io/yourselfhosted/slash:latest";
    ports = [ "127.0.0.1:3010:5231" ]; # Map local port to container port 5231
    volumes = [ "slash_data:/var/opt/slash" ];
  };
  # As this container is not available globally we need to configure traefik so it can handle the routing to the domain
  # it is better to have the config for the routing specific to the services instead of having it inn the traafik config for easy management.

  # Traefik configuration specific to littlelink
  services.traefik.dynamicConfigOptions.http = {
    services.slash.loadBalancer.servers = [ { url = "http://localhost:3010/"; } ]; # Access via local port

    # Router configuration for Slash
    routers.slash = {
      # rule = "Host(`thein3rovert.dev/slash`)"; # Your new domain path
      rule = "Host(`slash.thein3rovert.dev`)";
      tls = {
        certResolver = "godaddy";
      }; # SSL certificate configuration
      service = "slash"; # References the service defined above
      entryPoints = [ "websecure" ]; # Always use HTTPS endpoint for access
    };
  };
}
