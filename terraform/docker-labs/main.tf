terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = "unix:///run/user/1000/podman/podman.sock"  # Podman socket
}

variable "nginx_host" {
  description = "Nginx host configuration"
  type        = string
  default     = "localhost"
}

variable "nginx_port" {
  description = "Nginx port configuration"
  type        = string
  default     = "80"
}

resource "docker_image" "nginx" {
  name = "nginx:latest"
}

resource "docker_container" "web" {
  image = docker_image.nginx.image_id
  name  = "my-nginx-container"
  
  ports {
    internal = 80
    external = 8081
  }
  
  env = [
    "NGINX_HOST=${var.nginx_host}",
    "NGINX_PORT=${var.nginx_port}"
  ]
  
  restart = "unless-stopped"
}
