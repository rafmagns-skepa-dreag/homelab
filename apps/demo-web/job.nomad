job "demo-webapp" {
  datacenters = ["dc1"]

  group "demo" {
    count = 1

    network {
      port  "http"{
        to = 80
      }
    }

    service {
      name = "demo-webapp"
      port = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.demo-host.rule=Host(`app.rhlabs.us`, `app.traefik.service.consul`)",
      ]

      check {
        type     = "http"
        path     = "/"
        interval = "2s"
        timeout  = "2s"
      }
    }

    task "server" {
      env {
        PORT    = "${NOMAD_PORT_http}"
        NODE_IP = "${NOMAD_IP_http}"
      }

      driver = "docker"

      config {
        image = "trombone0/simple-web-arm:latest"
        ports = ["http"]
      }
    }
  }
}
