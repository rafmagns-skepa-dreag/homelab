variable "datacenter" {
  type = string
  default = "dc1"
}

variable "region" {
  type = string
  default = "global"
}

variable "version" {
  type = string
  default = "latest"
}

variable "cpu" {
  type = number
  default = 100
}

variable "memory" {
  type = number
  default = 100
}

variable "mbits" {
  type = number
  default = null
}

job "hashi-ui" {
  datacenters = [var.datacenter]
  region      = var.region
  type        = "service"

  update {
    stagger      = "30s"
    max_parallel = 1
  }

  group "hashi-ui" {
    count = 1

    network {
      port "http" {}
    }

    task "hashi-ui" {

      driver = "docker"

      config {
        image = "trombone0/hashi-ui:${var.version}"
        ports = ["http"]
      }

      service {
        name = "hashi-ui"
        tags = ["http", "ui",
          "traefik.enable=true",
          "traefik.http.routers.${NOMAD_TASK_NAME}.rule=Host(`${NOMAD_TASK_NAME}.traefik.service.consul`, `${NOMAD_TASK_NAME}.rhlabs.us`)", var.version]

        port = "http"

        check {
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }
      }

      env {
        NOMAD_ENABLE = 1
        NOMAD_ADDR   = "http://192.168.2.14:4646"
        CONSUL_ENABLE = 1
        CONSUL_ADDR = "http://192.168.2.14:8500"  # they run on the same server
      }

      resources {
        cpu    = var.cpu
        memory = var.memory
      }
    }
  }
}
