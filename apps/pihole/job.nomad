job "pihole" {
  region = "global"
  datacenters = ["dc1"]
  type = "service"

  group "pihole" {
    count = 1

    network {
      port "dns" {
        #static = 53
        to     = 53
      }
      port "http" {to = 80}
    }

    service {
      name = "pihole-gui"
      port = "http"
    }
    
    volume "dnsmasq" {
      type = "host"
      read_only = false
      source = "dnsmasq"
    }

    volume "pihole" {
      type = "host"
      read_only = false
      source = "pihole"
    }

    restart {
      attempts = 5
      delay    = "15s"
    }

    task "app" {
      driver = "docker"

      volume_mount {
        volume = "dnsmasq"
        destination = "/etc/dnsmasq.d"
        read_only = false
      }
      volume_mount {
        volume = "pihole"
        destination = "/etc/pihole"
        read_only = false
      }
      config {
        image = "pihole/pihole:latest"
        ports = ["dns", "http"]
        dns_servers = [
          "127.0.0.1",
          "1.1.1.1",
        ]
      }
      env = {
        "TZ"           = "America/Chicago"
        "WEBPASSWORD"  = "admin"
        # "INTERFACE"    = "eth0"
        # "VIRTUAL_HOST" = ""
        "ServerIP"     = "192.168.2.14"
        "PIHOLE_DNS_"  = "1.1.1.1;1.0.0.1"
      }
      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}
