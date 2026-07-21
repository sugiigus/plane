# Plane JP deployment files

These scripts are for `ai-server` only. They use the repository root Compose file, a separate `plane-jp` project name, named volumes, and a LAN-only binding.

1. Clone the `develop` branch into `/opt/plane-jp`.
2. Copy `deploy/.env.example` to `.env`, generate unique values, and create the matching `apps/*/.env` files from each official `.env.example`. Set all public URLs in `apps/api/.env` to `http://192.168.1.200:8085`.
3. Run `deploy/configure-lan-access.sh`, then `deploy/deploy.sh`. The access script installs and enables `plane-jp-firewall.service`, which restores the narrow Docker `DOCKER-USER` rule after Docker restarts and server reboots.
4. Run `deploy/healthcheck.sh`; from the allowed PC, open `http://192.168.1.200:8085`.

Never commit `.env`, backups, passwords, or generated keys. `backup.sh` writes a PostgreSQL dump, MinIO uploads archive, and permission-protected configuration copy. `update.sh` backs up, fast-forwards `develop`, rebuilds, and health-checks; it does not use destructive Compose or Docker prune commands.
