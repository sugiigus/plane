#!/usr/bin/env bash
set -euo pipefail

root_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$root_dir"

for required in .env apps/api/.env apps/web/.env apps/admin/.env apps/space/.env apps/live/.env; do
  [[ -f "$required" ]] || { echo "Missing $root_dir/$required" >&2; exit 1; }
done

compose=(docker compose -p plane-jp -f docker-compose.yml -f deploy/docker-compose.production.yml)
"${compose[@]}" config -q
"${compose[@]}" up -d --build
"$root_dir/deploy/healthcheck.sh"
echo "Plane JP deployment completed."
