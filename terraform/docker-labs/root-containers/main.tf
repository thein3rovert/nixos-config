terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = "unix:///run/podman/podman.sock"  # Root Podman socket
}

resource "docker_image" "nginx" {
  name = "nginx:latest"
}

resource "docker_container" "web" {
  image = docker_image.nginx.image_id
  name  = "my-nginx-container"
  
  # networks_advanced {
  #   name = "traefik_proxy"  # Connect to the Traefik network
  # }

  # network_mode = "host" this was causing the conflict
  network_mode = "host"

  # Configure nginx to listen on port 8082 instead of 80
  command = [
    "sh", "-c", 
    "sed -i 's/listen.*80;/listen 8082;/' /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"
  ]
    labels {
    label = "traefik.enable"
    value = "true"
  }
  
  labels {
    label = "traefik.http.routers.nginx.rule"
    value = "Host(`nginx.l.thein3rovert.com`)"
  }
  
  labels {
    label = "traefik.http.services.nginx.loadbalancer.server.port"
    value = "8082"
  }
  
  restart = "unless-stopped"
}
