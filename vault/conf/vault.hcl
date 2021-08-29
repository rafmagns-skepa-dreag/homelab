ui = true
disable_mlock = true

storage "raft" {
  path    = "/srv/vault/data"
  node_id = "node1"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = "true"
}

api_addr = "http://127.0.0.1:8200"
cluster_addr = "http://127.0.0.1:8201"

service_registration "consul" {
  address = "consul.service.consul:8500"
}
