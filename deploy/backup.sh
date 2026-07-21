#!/usr/bin/env bash
set -euo pipefail

root_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
backup_root=${BACKUP_ROOT:-"$root_dir/backups"}
timestamp=$(date +%Y%m%d-%H%M%S)
backup_dir="$backup_root/$timestamp"
umask 077
mkdir -p "$backup_dir"
cd "$root_dir"

if [[ ! -f .env ]]; then
  echo "Missing $root_dir/.env" >&2
  exit 1
fi

set -a
# shellcheck disable=SC1091
source ./.env
set +a

compose=(docker compose -p plane-jp -f docker-compose.yml -f deploy/docker-compose.production.yml)
"${compose[@]}" exec -T plane-db pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" -Fc > "$backup_dir/postgres.dump"

# Attachments are stored by the MinIO service in the uploads named volume.
docker run --rm -v plane-jp_uploads:/data:ro -v "$backup_dir:/backup" alpine:3.22 \
  tar -C /data -czf /backup/uploads.tar.gz .

cp .env "$backup_dir/root.env"
cp apps/api/.env "$backup_dir/api.env"
chmod 600 "$backup_dir/root.env" "$backup_dir/api.env"
sha256sum "$backup_dir"/* > "$backup_dir/SHA256SUMS"
echo "Backup created: $backup_dir"
