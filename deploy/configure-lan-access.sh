#!/usr/bin/env bash
set -euo pipefail

allowed_ip=${1:-192.168.1.7}
interface=${2:-wlp5s0}
container_port=${3:-80}
server_ip=${4:-192.168.1.200}
host_port=${5:-8085}
chain=PLANE_JP

sudo ufw allow from "$allowed_ip" to "$server_ip" port "$host_port" proto tcp comment 'plane-jp main PC'
sudo iptables -N "$chain" 2>/dev/null || true
sudo iptables -F "$chain"
sudo iptables -A "$chain" -s "$allowed_ip" -j ACCEPT
sudo iptables -A "$chain" -j DROP
sudo iptables -C DOCKER-USER -i "$interface" -p tcp --dport "$container_port" -j "$chain" 2>/dev/null || \
  sudo iptables -I DOCKER-USER 1 -i "$interface" -p tcp --dport "$container_port" -j "$chain"

if command -v netfilter-persistent >/dev/null; then
  sudo netfilter-persistent save
else
  echo "WARNING: install and configure iptables-persistent to retain the DOCKER-USER rule after reboot." >&2
fi

echo "Restricted Plane HTTP to $allowed_ip (host $server_ip:$host_port, container port $container_port)."
