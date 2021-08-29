Need to set VAULT_ADDR=http://127.0.0.1:8200
and VAULT_TOKEN=<root token> to use the vault cli
check nomad docs for more info - https://www.nomadproject.io/docs/integrations/vault-integration

https://github.com/raspberrypi/linux/issues/1198
sudoedit /boot/firmware/cmdline.txt and add cgroup_enable=memory cgroup_memory=1

sudoedit /etc/systemd/resolved.conf
[Resolve]
DNS=192.168.2.14
Domains=~consul

# port 53 requires root
sudo /home/ubuntu/.bin/consul agent -dev -config-dir consul.d/ -client 192.168.2.14 -dns-port 53
sudo $HOME/.bin/nomad agent -config nomad.hcl
sudo $HOME/.bin/nomad agent -client -config nomad-cluster.hcl
vault server -config=vault/config

4/14
I gave up on getting podman to be 1. rootless, 2. working properly with my private IP space, 3. using DHCP
nomad doesn't allow local docker images
nomad doesn't allow local files to be used as artifacts

4/15
fixed issues - 
put image up on docker hub
working to get CNI dhcp plugin enabled - https://github.com/containernetworking/plugins/tree/master/plugins/ipam/dhcp/systemd

always add hostname to /etc/hosts to make sure sudo works
installed consul via the forked hashicorp config repo
this installs dnsmasq. make sure that 192.168.1.1 (router IP) is in /etc/resolv.conf

4/29
make sure that ports 80 and 443 are forwarded on the router

8/22
you can add the old network so that you can boot and then update the config :facepalm:
updated:
  * pi server IP
  * router IP
  * IP for rhlabs.us at NoIP (UDM will only auto-update on IP change/restart)
port forwarding: 
  * 80, 443
