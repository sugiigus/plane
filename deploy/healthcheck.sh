#!/usr/bin/env bash
set -euo pipefail

root_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$root_dir"

if [[ ! -f .env ]]; then
  echo "Missing $root_dir/.env" >&2
  exit 1
fi

# LISTEN_HTTP_PORT is intentionally an IP:port binding, e.g. 192.168.1.200:8085.
listen=$(grep -E '^LISTEN_HTTP_PORT=' .env | tail -n1 | cut -d= -f2- | tr -d '"')
host=${listen%:*}
port=${listen##*:}
url="http://${host}:${port}/api/instances/"

for attempt in $(seq 1 30); do
  if curl --fail --silent --show-error "$url" >/dev/null; then
    echo "Healthy: $url"
    exit 0
  fi
  sleep 2
done

echo "Health check failed: $url" >&2
docker compose -p plane-jp -f docker-compose.yml -f deploy/docker-compose.production.yml ps >&2 || true
exit 1
