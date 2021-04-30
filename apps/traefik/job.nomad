job "traefik" {
  region      = "global"
  datacenters = ["dc1"]
  type        = "service"

  group "traefik" {
    count = 1

    network {
      port "http" {
        static = 80
      }

      port "api" {
        static = 8081
      }
    }

    service {
      name = "traefik"
      tags = ["app", "nomad", "facto", "mariadb",
        "traefik.enable=true",
        "traefik.http.middlewares.traefik-auth.basicauth.users=admin:admin",
        "traefik.http.middlewares.traefik-https-redirect.redirectscheme.scheme=https",
        "traefik.http.middlewares.sslheader.headers.customrequestheaders.X-Forwarded-Proto=https",

        "traefik.http.routers.traefik-dash.entrypoints=http",
        "traefik.http.routers.traefik-dash.middlewares=traefik-https-redirect",
        "traefik.http.routers.traefik-dash.rule=Host(`traefik.rhlabs.dev`)",
        "traefik.http.routers.traefik-dash.service=dashboard@internal",

        "traefik.http.routers.traefik-dash2.entrypoints=https",
        "traefik.http.routers.traefik-dash2.middlewares=traefik-https-redirect",
        "traefik.http.routers.traefik-dash2.rule=Host(`traefik.rhlabs.dev`)",
        "traefik.http.routers.traefik-dash2.service=dashboard@internal",
        "traefik.http.routers.traefik-dash2.tls.certResolver=cloudflare",
        "traefik.http.routers.traefik-dash2.tls.domains[0].main=rhlabs.dev",
        "traefik.http.routers.traefik-dash2.tls.domains[0].sans=*.rhlabs.dev",

        "traefik.http.routers.traefik-api.entrypoints=https",
        "traefik.http.routers.traefik-api.rule=Host(`traefik.rhlabs.dev`) && PathPrefix(`/api`)",
        #"traefik.http.routers.traefik-api.middlewares=traefik-auth",
        "traefik.http.routers.traefik-api.service=api@internal",
        "traefik.http.routers.traefik-api.tls.certResolver=cloudflare",
        "traefik.http.routers.traefik-api.tls.domains[0].main=rhlabs.dev",
        "traefik.http.routers.traefik-api.tls.domains[0].sans=*.rhlabs.dev",

        "traefik.http.routers.traefik-dash-insecure.rule=Host(`traefik.rhlabs.us`)",
        "traefik.http.routers.traefik-dash-insecure.service=dashboard@internal",
        "traefik.http.routers.traefik-api-insecure.rule=Host(`traefik.rhlabs.us`) && PathPrefix(`/api`)",
        "traefik.http.routers.traefik-api-insecure.service=api@internal"
      ]

      check {
        name     = "alive"
        type     = "tcp"
        port     = "http"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "traefik" {
      driver = "docker"

      config {
        image        = "traefik:v2.2"
        network_mode = "host"
        volumes = ["local/traefik.toml:/etc/traefik/traefik.toml"]
      }

      env {
        # These must be set
        # TODO pull from vault
        CLOUDFLARE_EMAIL = ""
        CLOUDFLARE_API_KEY = ""
      }

      template {
        destination = "local/traefik.toml"
        data = <<EOH
[entryPoints]
[entryPoints.http]
address = ":80"
[entryPoints.traefik]
address = ":8081"
[entryPoints.https]
address = ":443"
[accessLog]

[serversTransport]
  insecureSkipVerify = true

[log]
  level = "DEBUG"

[api]
    dashboard = true
    debug = true
    insecure  = true

[providers]
  # Enable Consul Catalog configuration backend.
  [providers.consulCatalog]
      prefix           = "traefik"
      exposedByDefault = false

      [providers.consulCatalog.endpoint]
        address = "192.168.1.3:8500"
        scheme  = "http"
  [providers.file]
    filename = "/local/dynamic.toml"

[certificatesResolvers.cloudflare.acme]
email = "richard.sonofhans@gmail.com"
storage = "acme.json"
[certificatesResolvers.cloudflare.acme.dnsChallenge]
provider = "cloudflare"
resolvers = ["1.1.1.1:53", "1.0.0.1:53"]
EOH
      }

      template {
        destination = "local/dynamic.toml"
        data = <<EOH
[http]
  [http.routers]
    [http.routers.nomad]
      rule = "Host(`nomad.rhlabs.us`, `nomad.rhlabs.dev`, `nomad.rhlabs.app`)"
      service = "nomad"

  [http.services]
    [http.services.nomad.loadBalancer]
      [[http.services.nomad.loadBalancer.servers]]
        url = "http://192.168.1.3:4646"

[http.middlewares]
[http.middlewares.https-redirect]
[http.middlewares.https-redirect.redirectScheme]
scheme = "https"

EOH
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}
