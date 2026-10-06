#!/usr/bin/env bash
# Déploie une version de l'application sur le serveur cible.
# Usage : ./scripts/deploy.sh <version>
set -euo pipefail

VERSION="${1:?Usage: $0 <version>}"

echo "Déploiement de la version ${VERSION}"
export APP_VERSION="${VERSION}"

docker compose pull app
docker compose up -d app
