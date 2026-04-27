terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {
  host = "npipe:////./pipe/docker_engine"
}

resource "docker_image" "stats_app" {
  name         = "stats-app:latest"
  keep_locally = true
}

resource "docker_container" "stats_server" {
  image = docker_image.stats_app.image_id
  name  = "server-via-terraform"
  ports {
    internal = 8080
    external = 9000
  }
}
