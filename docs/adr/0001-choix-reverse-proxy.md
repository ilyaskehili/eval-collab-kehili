# ADR 0001 – Choix du reverse proxy : Traefik

- **Statut** : accepté
- **Date** : 2026-10-06
- **Décideurs** : équipe infra (@ilyaskehili)

## Contexte
- L'équipe héberge une **quinzaine de services** en conteneurs Docker, répartis sur **deux serveurs**.
- **De nouveaux services sont ajoutés chaque mois** : avec Nginx, chacun impose d'écrire un bloc `server`, de recharger la configuration et de tester, sur le bon serveur.
- Le **renouvellement des certificats TLS est manuel** et a **déjà provoqué une coupure** quand un certificat a expiré.
- L'équipe **connaît bien Nginx**, mais **pas Traefik**.

## Options envisagées
1. **Nginx** (situation actuelle), éventuellement complété par Certbot et un cron pour le renouvellement.
2. **Traefik**, reverse proxy qui découvre les conteneurs via les labels Docker et gère les certificats ACME (Let's Encrypt).

| Critère | Nginx (+ Certbot) | Traefik |
|---|---|---|
| Ajout d'un service | Bloc `server` écrit à la main + rechargement | Quelques labels dans le `docker-compose.yml` du service |
| Certificats TLS | Certbot + cron + rechargement de Nginx à scripter et surveiller | Obtention et renouvellement automatiques intégrés |
| Compétences de l'équipe | Maîtrisé | À apprendre |
| Performance / maturité | Très élevées | Suffisantes pour 15 services internes |
| Observabilité | Logs, module status | Tableau de bord, métriques Prometheus intégrées |

## Décision
Nous adoptons **Traefik (v3)** comme reverse proxy sur les deux serveurs, avec la découverte par **labels Docker** et le **renouvellement automatique des certificats via ACME**.

## Justification
- **Le renouvellement automatique des certificats supprime la cause de la coupure déjà subie.** C'est le risque le plus grave du contexte. Avec Nginx, il faudrait l'outiller (Certbot, cron, rechargement, supervision), soit une chaîne de plus à maintenir.
- **L'ajout mensuel de services devient déclaratif** : la configuration de routage vit avec le service, dans son `docker-compose.yml`, et passe par la même PR. On évite un fichier Nginx central à modifier à chaque fois, source d'erreurs et de conflits.
- Pour une quinzaine de services, la différence de performance avec Nginx n'est pas un critère décisif.
- Le manque de compétences sur Traefik est réel, mais il se traite par de la formation et une migration progressive. Le coût d'apprentissage est ponctuel, alors que le travail manuel avec Nginx revient chaque mois.

## Conséquences
### Positives
- Plus de renouvellement manuel des certificats, donc plus de coupure liée à leur expiration.
- Mise en ligne d'un nouveau service réduite à l'ajout de labels, relue en PR.
- Tableau de bord et métriques pour voir les routes actives.

### Négatives
- **Montée en compétence nécessaire** : l'équipe ne connaît pas Traefik, donc les premiers incidents seront plus longs à diagnostiquer.
- Traefik doit accéder au socket Docker : c'est une surface d'attaque à limiter (socket proxy en lecture seule, tableau de bord non exposé publiquement).
- Le stockage ACME (`acme.json`) doit être persistant, protégé (`chmod 600`) et sauvegardé, sinon on risque d'atteindre les limites de Let's Encrypt.
- Pendant la transition, deux technologies coexistent.

### Actions de suivi
- [ ] Formation de l'équipe à Traefik (documentation officielle + atelier interne).
- [ ] Maquette sur un service non critique, puis migration service par service ; Nginx reste en place jusqu'à la bascule complète, ce qui permet un retour arrière.
- [ ] Mettre en place la supervision de l'expiration des certificats (alerte à J-14) comme filet de sécurité.
- [ ] Documenter dans le README les labels Traefik types pour ajouter un service.
- [ ] Revoir cette décision après 3 mois d'exploitation.
