# AGENTS.md

Consignes pour les agents IA (et les humains) qui interviennent sur ce dépôt.

## Contexte du projet
- Dépôt d'**infrastructure** de l'application *intranet* : Docker Compose (`proxy` Nginx, `app`, `db` PostgreSQL), configuration du reverse proxy et scripts d'exploitation.
- Le code applicatif n'est pas ici : l'application arrive sous forme d'image (`registry.example.local/intranet/app`).
- Fichiers clés : `docker-compose.yml`, `proxy/nginx.conf`, `scripts/deploy.sh`, `scripts/backup.sh`, `Makefile`, `docs/adr/`.
- Les décisions d'architecture sont tracées dans `docs/adr/` ; lis-les avant de proposer un changement structurant (ex. [ADR 0001](docs/adr/0001-choix-reverse-proxy.md) sur le reverse proxy).

## Commandes de vérification
À lancer avant de proposer une modification. Elles doivent toutes passer :
```bash
make check                     # shellcheck scripts/*.sh + docker compose config --quiet
shellcheck scripts/*.sh        # lint des scripts shell seul
docker compose config --quiet  # validation de docker-compose.yml seul
```
Si une vérification échoue, corrige la cause ou signale-la dans la PR. Ne la contourne pas.

## Conventions
- **Branches** : `<type>/<n° issue>-<sujet>` (ex. `fix/1-vpn-firewall`, `docs/2-documentation`).
- **Commits** : [Conventional Commits](https://www.conventionalcommits.org/fr/), en anglais, à l'impératif (`fix(deploy): …`, `docs(readme): …`, `chore: …`).
- **Pull requests** : toujours vers `main`, en remplissant le modèle, avec `Closes #n` ; merge en *Squash and merge*.
- **Scripts shell** : `#!/usr/bin/env bash`, `set -euo pipefail`, variables entre guillemets, arguments validés (`${1:?usage}`).
- **Docker** : images avec une version précise (pas de `latest`) ; seuls les ports du `proxy` sont publiés sur l'hôte.
- **Configuration** : les variables vont dans `.env` (non versionné) ; documente toute nouvelle variable dans `.env.example`.

## Interdits
- **Ne jamais committer de secret** (mot de passe, jeton, clé privée, certificat) : utilise `.env` ou le gestionnaire de secrets de l'équipe. Si tu en trouves un dans le dépôt, signale-le pour qu'il soit révoqué.
- **Ne jamais pousser directement sur `main`** : passe toujours par une PR.
- **Ne jamais désactiver, supprimer ou contourner une vérification** (tests, lint, hooks, `--no-verify`) pour faire passer une modification.
- Ne pas te connecter aux serveurs ni lancer de déploiement en production : tu prépares des modifications, un humain les applique.
- Pas de commande destructrice sans validation explicite d'un humain (`docker compose down -v`, `rm -rf`, suppression de volume ou de sauvegarde).
- Pas de `chmod 777`, de `curl … | bash` ni de `StrictHostKeyChecking=no`.
- Ne modifie pas `.github/CODEOWNERS` ni la protection de branche.
