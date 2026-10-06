#!/usr/bin/env bash
# Sauvegarde la base PostgreSQL dans ./backups.
set -euo pipefail

mkdir -p backups
docker compose exec -T db pg_dump -U "${POSTGRES_USER:-intranet}" "${POSTGRES_DB:-intranet}" \
  | gzip > "backups/db-$(date +%Y%m%d-%H%M%S).sql.gz"
