# Intranet – socle d'hébergement

## Description
Ce dépôt contient l'infrastructure de l'application **intranet** : la définition des conteneurs (`docker-compose.yml`), la configuration du reverse proxy Nginx (`proxy/nginx.conf`) et les scripts d'exploitation (déploiement, sauvegarde).

L'application elle-même est construite ailleurs et publiée sous forme d'image dans le registre `registry.example.local/intranet/app`. *(Supposé : le dépôt du code applicatif n'est pas référencé ici.)*

## Architecture
Trois services Docker Compose :

| Service | Image | Rôle | Exposition |
|---------|-------|------|------------|
| `proxy` | `nginx:1.27-alpine` | Reverse proxy, terminaison TLS, redirection HTTP → HTTPS | ports 80 et 443 de l'hôte |
| `app` | `registry.example.local/intranet/app:${APP_VERSION}` | Application web (port interne 8080, healthcheck sur `/health`) | réseau Docker interne |
| `db` | `postgres:16-alpine` | Base de données, volume persistant `db-data` | réseau Docker interne |

Le domaine servi est `intranet.example.local`. Les certificats TLS sont lus dans `proxy/certs/` (`fullchain.pem`, `privkey.pem`) et **renouvelés à la main** *(supposé d'après l'absence d'outil de renouvellement ; voir [ADR 0001](docs/adr/0001-choix-reverse-proxy.md))*.

## Prérequis
- Docker Engine et le plugin **Docker Compose v2** (`docker compose`)
- `make`
- [`shellcheck`](https://www.shellcheck.net/) pour les vérifications
- Un accès en lecture au registre `registry.example.local` *(supposé : authentification par `docker login`)*
- Des certificats TLS valides pour `intranet.example.local`

## Installation
```bash
git clone https://github.com/ilyaskehili/eval-collab-kehili.git
cd eval-collab-kehili
cp .env.example .env          # puis renseigner un vrai POSTGRES_PASSWORD
mkdir -p proxy/certs          # y déposer fullchain.pem et privkey.pem
make up                       # docker compose up -d
```
Le fichier `.env` et le dossier `proxy/certs/` sont ignorés par Git : ils ne doivent jamais être committés.

## Déploiement
Déployer une version précise de l'application :
```bash
./scripts/deploy.sh 1.2.0
```
Le script exporte `APP_VERSION`, tire la nouvelle image et recrée uniquement le service `app` (le proxy et la base ne sont pas redémarrés).

Sauvegarder la base avant une mise à jour :
```bash
./scripts/backup.sh           # crée backups/db-AAAAMMJJ-HHMMSS.sql.gz
```

Arrêter la pile : `make down`.

## Vérifications
```bash
make check
```
Cette commande lance `shellcheck` sur `scripts/*.sh` et valide la syntaxe de `docker-compose.yml` (`docker compose config --quiet`). Elle doit passer avant toute PR.

## Structure du dépôt
```
.
├── .github/
│   ├── CODEOWNERS                 # propriétaire du dépôt (revue obligatoire)
│   ├── ISSUE_TEMPLATE/            # modèles « Bug / incident » et « Évolution / documentation »
│   └── pull_request_template.md   # modèle de description de PR
├── docs/adr/                      # décisions d'architecture (ADR)
├── proxy/nginx.conf               # configuration du reverse proxy
├── scripts/
│   ├── deploy.sh                  # déploiement d'une version
│   └── backup.sh                  # sauvegarde PostgreSQL
├── docker-compose.yml
├── .env.example                   # variables à copier dans .env
├── Makefile                       # lint, check, up, down
└── AGENTS.md                      # consignes pour les agents IA
```

## Contribuer
- La branche `main` est protégée : toute modification passe par une **pull request**.
- Nommer les branches `<type>/<n° issue>-<sujet>` (ex. `docs/2-documentation`, `fix/1-vpn-firewall`).
- Messages de commit au format **[Conventional Commits](https://www.conventionalcommits.org/fr/)** : `feat:`, `fix:`, `docs(readme):`, `chore:`…
- Ouvrir une issue avec le modèle adapté avant de commencer, puis la référencer dans la PR (`Closes #n`).
- Les relectures suivent **[Conventional Comments](https://conventionalcomments.org/)** (`issue (blocking): …`, `suggestion (non-blocking): …`).
- `make check` doit passer ; aucun secret ne doit être committé.

## Contact
Responsable du dépôt : **@ilyaskehili** (voir `.github/CODEOWNERS`).
