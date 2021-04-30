data_dir = "/var/lib/nomad"

bind_addr = "0.0.0.0"

log_level = "INFO"

vault {
  enabled = true
  # token = ""
  create_from_role = "nomad-cluster"
  address = "http://127.0.0.1:8200"
}

consul {
  address = "192.168.1.3:8500"
  verify_ssl = false
  server_service_name = "nomad"
  client_service_name = "nomad-client"
  auto_advertise = true
  server_auto_join = true
  client_auto_join = true
}

server {
  bootstrap_expect = 1
  enabled = true
}
