# Digital Chantier — ERP BTP

ERP web interne de gestion de chantiers (bâtiment & travaux publics) pour une entreprise
basée à Mahajanga, Madagascar. Transparence totale : traçabilité de chaque action, chaque
Ariary, chaque heure de chantier.

## Stack technique

- **Backend** : PHP 8.2+ pur, architecture MVC maison légère (pas de framework)
- **Base de données** : MySQL 8 / MariaDB (SQL portable)
- **Frontend** : HTML5 / CSS3 / JavaScript vanilla, pages servies par PHP + appels `fetch` vers l'API
- **API** : REST JSON sous `/api/v1/`, sécurisée par JWT (dès la Phase 1) — consommée à l'identique par le futur mobile React Native
- **Auth** : JWT HS256 fait maison (access + refresh)
- **E-mail** : PHPMailer via SMTP authentifié pour les codes OTP
- **Hébergement cible** : Simafri (mutualisé) — tout tourne en PHP/MySQL, tâches planifiées via cron cPanel

## Arborescence

```
BTP_ERP/
├── public/                 ← racine web (à pointer sur Simafri)
│   ├── index.php           ← front controller unique
│   ├── .htaccess           ← réécriture d'URL
│   └── assets/             ← css, js
├── app/
│   ├── Core/               ← socle maison (Router, Request, Response, Database, Jwt, Audit…)
│   ├── Controllers/
│   │   ├── Api/            ← contrôleurs API (JSON)
│   │   └── Web/            ← contrôleurs pages (HTML)
│   ├── Models/             ← modèles (accès données)
│   ├── Middleware/         ← auth, contrôle de rôle (Phase 1)
│   ├── Views/              ← gabarits PHP
│   └── Helpers/            ← fonctions globales (format Ariary…)
├── routes/                 ← api.php + web.php
├── database/migrations/    ← fichiers SQL versionnés (0001_…, 0002_…)
├── storage/logs/           ← journaux applicatifs
├── cli.php                 ← console (migrations, seeds) — utilisable en cron
└── .env                    ← configuration locale (non commité)
```

## Installation / test (local XAMPP)

1. Démarrer Apache + MySQL dans XAMPP.
2. Copier `.env.example` en `.env` et vérifier les identifiants MySQL.
3. Appliquer les migrations :
   ```bash
   /Applications/XAMPP/xamppfiles/bin/php cli.php migrate
   ```
4. Ouvrir **http://localhost/BTP_ERP/public/** dans le navigateur.
   La page d'accueil interroge l'API et affiche l'état du socle.

### Vérifier l'API directement

```bash
curl http://localhost/BTP_ERP/public/api/v1/health
```

Réponse attendue :
```json
{ "succes": true, "message": "API operationnelle",
  "donnees": { "base_donnees": "connectee", "php": "8.2.4", ... } }
```

## Point d'entrée & structure web

Le front controller est **à la racine** (`index.php`). En production Simafri, faire pointer
le domaine sur la racine du projet ; `.env`, `app/`, `database/`, `storage/`, `routes/` sont
protégés par `.htaccess`.

## Authentification (Phase 1)

Créer le premier compte :
```bash
# Compte de démonstration (directeur / mot de passe provisoire)
php cli.php seed
# ou compte sur mesure :
php cli.php creer-admin email@entreprise.mg "Nom" "MotDePasse8+" directeur
```
Compte de démo : `directeur@digitalchantier.mg` / `Directeur@2026` (à changer à la 1re connexion).

Endpoints (`/api/v1/auth/`) : `login`, `refresh`, `logout`, `mot-de-passe-oublie`, `reinitialiser-mot-de-passe` (public) ; `me`, `mot-de-passe` (protégés, `Authorization: Bearer <access_token>`).

Mot de passe oublie : l'interface `/mot-de-passe-oublie` envoie un code OTP de 6 chiffres valable 15 minutes via PHPMailer. Configurer dans `.env` :
```env
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=votre-adresse@gmail.com
MAIL_PASSWORD=votre-mot-de-passe-application
MAIL_ENCRYPTION=tls
MAIL_FROM=votre-adresse@gmail.com
MAIL_FROM_NAME="Digital Chantier"
```
Pour Gmail, `MAIL_FROM` doit correspondre au compte `MAIL_USERNAME`. Utiliser un mot de passe d'application Google (pas le mot de passe habituel), puis redémarrer Apache.

En production, configurez ces mêmes paramètres dans le `.env` privé du serveur, jamais dans le dépôt public. Remplacez les exemples par les paramètres SMTP de l'hébergeur ou du prestataire e-mail ; `MAIL_FROM` doit être une adresse vérifiée/autorisée par celui-ci. Utilisez `tls` avec le port STARTTLS (souvent 587) ou `ssl` avec le port TLS implicite (souvent 465), selon les consignes du prestataire. Le serveur doit autoriser les connexions sortantes vers son SMTP. Pour la délivrabilité avec un domaine personnalisé, configurez également les enregistrements DNS SPF et DKIM du prestataire, ainsi qu'une politique DMARC.

Pour déployer, installez les dépendances PHP avec `composer install --no-dev --optimize-autoloader`, appliquez les migrations avec `php cli.php migrate` et définissez `APP_ENV=production` et `APP_DEBUG=false`. En cas d'échec d'envoi, consultez `storage/logs/`.

- **Web** : access token en mémoire JS, refresh token en cookie `httpOnly`. Pages `/connexion` et `/tableau-de-bord`.
- **Mobile** : envoyer `{"client":"mobile"}` au login → refresh token renvoyé dans le corps JSON.
- Rôles : `directeur` (accès total), `chef_chantier`, `comptable`, `magasinier`.

Purge des tokens obsolètes (cron cPanel conseillé) : `php cli.php purger-tokens`.

## Référentiels (Phase 2)

CRUD des 5 référentiels (employés, clients, fournisseurs, engins, matériaux) :
- **API** : `/api/v1/{employes|clients|fournisseurs|engins|materiaux}` (GET liste `?page=&limite=&recherche=`, GET `/{id}`, POST, PUT `/{id}`, DELETE `/{id}`). Lecture = tout utilisateur connecté ; écriture = rôles dédiés (directeur = tout).
- **Web** : `/referentiels` (sommaire), `/referentiels/{entite}` (liste AJAX + recherche), `/referentiels/{entite}/nouveau` et `/{id}/modifier` (formulaire).
- Ajouter un référentiel = 1 migration + 1 modèle + 1 contrôleur (héritant de `ResourceController`) + 1 route + 1 entrée dans `app/Config/referentiels.php` (pilote tableaux **et** formulaires).

## Chantiers & lots (Phase 3)

- **API** : `/api/v1/chantiers` (CRUD ; liste avec nom client/responsable ; détail avec lots + avancement pondéré). Lots imbriqués : `GET/POST /api/v1/chantiers/{id}/lots`, `PUT/DELETE /api/v1/lots/{id}`. Liste comptes : `GET /api/v1/utilisateurs`. Écriture réservée à directeur + chef_chantier.
- **Web** : `/chantiers` (liste), `/chantiers/nouveau`, `/chantiers/{id}` (détail + gestion des lots avec jauges d'avancement), `/chantiers/{id}/modifier`.
- **Lots** : lecture pour tous les rôles ; création, modification et suppression (avec confirmation) réservées au directeur et au chef de chantier, sur le web et le mobile.
- Un chantier a un type (bâtiment/route/autre), un client, un responsable (chef de chantier), un budget prévisionnel et un statut. L'avancement global est la moyenne des lots **pondérée par leur budget**.

## Pointage

- `/chantiers/{id}/pointage` est consultable par le directeur, le chef de chantier, le comptable et le magasinier.
- La saisie et la modification de la feuille sont réservées au directeur et au chef de chantier ; les autres rôles disposent d'un écran en lecture seule.
- Sur mobile, ouvrir un chantier depuis la liste donne accès aux lots et à sa feuille de pointage. L'enregistrement actuel fait office de validation ; il n'y a pas de statut de validation distinct.

## Convention de réponse API

- Succès : `{ "succes": true,  "message": "...", "donnees": ... }`
- Erreur  : `{ "succes": false, "message": "...", "erreurs": {...} }`

## Feuille de route

| Phase | Contenu | État |
|-------|---------|------|
| **0** | Socle MVC, routeur, API, JWT (moteur), migrations, audit | ✅ Terminé |
| **1** | Authentification JWT (login/refresh/logout/me), utilisateurs, RBAC | ✅ Terminé |
| **2** | Référentiels : employés, clients, fournisseurs, engins, matériaux (CRUD API + web) | ✅ Terminé |
| **3** | Chantiers (bâtiment/route) + lots, budgets, avancement, responsable | ✅ Terminé |
| **4** | Pointage & main d'œuvre (feuille journalière, coût figé) | ✅ Terminé |
| **5** | Achats (en-tête+lignes), réception→stock, mouvements de stock | ✅ Terminé |
| **6** | Devis → facture (HT/TVA/TTC), paiements, statuts auto | ✅ Terminé |
| **7** | Suivi financier : KPIs, rentabilité chantier, trésorerie | ✅ Terminé |
| **8** | Journal d'audit, facture imprimable (PDF), cron (relances, sauvegarde) | ✅ Terminé |
| **9** | Durcissement (CORS, en-têtes, anti-bruteforce) & préparation mobile | ✅ Terminé |

## Tâches planifiées (cron cPanel Simafri)

```
# Purge des refresh tokens obsolètes (quotidien)
0 2 * * *  php /home/USER/public_html/cli.php purger-tokens
# Relances des factures échues (quotidien)
0 7 * * *  php /home/USER/public_html/cli.php relances
# Sauvegarde de la base (quotidien)
0 3 * * *  php /home/USER/public_html/cli.php sauvegarde
```

## Personnalisation & démonstration

**Charte graphique** (sans toucher au code) — dans `.env` :
```
APP_NAME="Nom de votre entreprise"
BRAND_COLOR="#2c6ea4"   # couleur principale (boutons, liens, logo, éléments actifs)
BRAND_SIGLE="DC"        # sigle affiché dans le logo
```

**Jeu de données de démonstration** (6 mois de données réalistes pour un tableau de bord parlant) :
```
php cli.php demo
```
Crée 5 chantiers, référentiels, achats, pointages, 6 factures + paiements répartis sur 6 mois, et les comptes `hery.chef@`, `naina.compta@`, `paul.magasin@` (mot de passe `Demo@2026`).

**Anti-lockout** — réinitialiser un mot de passe si besoin :
```
php cli.php reset-mdp directeur@digitalchantier.mg Directeur@2026
```

**Terrain** : la feuille de pointage affiche des libellés bilingues français / malgache (présences : *Andro feno*, *Antsasak'andro*, *Tsy tonga*).

> Montants : les colonnes monétaires sont en `BIGINT` (migration 0008) pour gérer les marchés de plusieurs milliards d'Ariary.

## Durcissement production (checklist)

- [ ] `APP_ENV=production` et `APP_DEBUG=false` dans `.env`
- [ ] `JWT_SECRET` régénéré (chaîne aléatoire longue et unique)
- [ ] Mot de passe MySQL fort ; mot de passe du compte directeur changé
- [ ] Domaine pointé sur la **racine** du projet ; HTTPS activé (cookies `secure` automatiques hors `local`)
- [ ] Vérifier que `.env`, `app/`, `database/`, `storage/`, `routes/` renvoient 403 en accès direct
- [ ] Crons configurés (voir ci-dessus)

## API pour le mobile (React Native)

L'API est la **source unique de vérité**, identique pour le web et le mobile.
- Base URL : `https://votre-domaine.mg/api/v1`
- Connexion : `POST /api/v1/auth/login` avec `{"email","mot_de_passe","client":"mobile"}` → renvoie `access_token` **et** `refresh_token` dans le corps JSON (le mobile les stocke de façon sécurisée).
- Requêtes authentifiées : en-tête `Authorization: Bearer <access_token>`.
- Rafraîchissement : `POST /api/v1/auth/refresh` avec `{"refresh_token":"..."}`.
- CORS activé (l'origine appelante est reflétée) ; requêtes `OPTIONS` de préflight gérées.
- Enveloppe de réponse identique partout : `{ "succes", "message", "donnees" }`.

Rôles prévus : `directeur` (admin), `chef_chantier`, `comptable`, `magasinier`.
