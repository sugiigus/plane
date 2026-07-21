#!/usr/bin/env bash
set -euo pipefail

# Restrict the Docker-published Plane HTTP port after DNAT. Values are fixed to
# the LAN deployment documented in this repository; change this file and run
# deploy/configure-lan-access.sh again if the server network changes.
chain=PLANE_JP
allowed_ip=192.168.1.7
interface=wlp5s0
container_port=80

iptables -N "$chain" 2>/dev/null || true
iptables -F "$chain"
iptables -A "$chain" -s "$allowed_ip" -j ACCEPT
iptables -A "$chain" -j DROP
iptables -C DOCKER-USER -i "$interface" -p tcp --dport "$container_port" -j "$chain" 2>/dev/null || \
  iptables -I DOCKER-USER 1 -i "$interface" -p tcp --dport "$container_port" -j "$chain"
