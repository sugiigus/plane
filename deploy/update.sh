#!/usr/bin/env bash
set -euo pipefail

root_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$root_dir"

current=$(git rev-parse --short HEAD)
echo "Current revision: $current"
"$root_dir/deploy/backup.sh"
git fetch origin develop
git switch develop
git pull --ff-only origin develop

if ! "$root_dir/deploy/deploy.sh"; then
  echo "Deployment failed. To return to $current: git switch --detach $current && deploy/deploy.sh" >&2
  exit 1
fi

echo "Updated from $current to $(git rev-parse --short HEAD)"
