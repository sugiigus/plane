#!/usr/bin/env bash
set -euo pipefail

allowed_ip=${1:-192.168.1.7}
interface=${2:-wlp5s0}
container_port=${3:-80}
server_ip=${4:-192.168.1.200}
host_port=${5:-8085}
root_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

if [[ "$allowed_ip" != "192.168.1.7" || "$interface" != "wlp5s0" || "$container_port" != "80" || "$server_ip" != "192.168.1.200" || "$host_port" != "8085" ]]; then
  echo "This deployment's persistent firewall unit is fixed to 192.168.1.7 -> 192.168.1.200:8085 via wlp5s0. Update deploy/plane-jp-firewall.sh before changing these values." >&2
  exit 2
fi

sudo ufw allow from "$allowed_ip" to "$server_ip" port "$host_port" proto tcp comment 'plane-jp main PC'

# Docker's own forwarding rules can bypass UFW.  Install a narrow DOCKER-USER
# rule as a systemd unit so Docker restarts and server reboots restore it.
sudo install -m 0755 "$root_dir/deploy/plane-jp-firewall.sh" /usr/local/sbin/plane-jp-firewall
sudo install -m 0644 "$root_dir/deploy/plane-jp-firewall.service" /etc/systemd/system/plane-jp-firewall.service
sudo systemctl daemon-reload
sudo systemctl enable --now plane-jp-firewall.service

echo "Restricted Plane HTTP to $allowed_ip (host $server_ip:$host_port, container port $container_port)."
