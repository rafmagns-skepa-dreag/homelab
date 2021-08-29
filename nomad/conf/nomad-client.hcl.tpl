data_dir = "/var/lib/nomad"

bind_addr = "0.0.0.0"

ports = {
  http = 4848
  rpc = 4849
  serf = 4850
}

log_level = "INFO"

vault {
  enabled = true
  token = "{{ nomad_vault_token }}"
  create_from_role = "nomad-cluster"
  address = "http://127.0.0.1:8200"
}

consul {
  address = "192.168.2.14:8500"
  verify_ssl = false
  server_service_name = "nomad"
  client_service_name = "nomad-client"
  auto_advertise = true
  server_auto_join = true
  client_auto_join = true
}

client {
  enabled = true
  servers = ["192.168.2.14"]
  host_volume "mariadb" {
    path = "/home/ubuntu/mariadb"
    read_only = false
  }
  host_volume "dnsmasq" {
    path = "/etc/dnsmasq.d"
    read_only = false
  }
  host_volume "pihole" {
    path = "/etc/pihole"
    read_only = false
  }
}
