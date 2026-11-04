# Digital Chantier — ERP BTP

> ERP Web et mobile de gestion de chantiers (bâtiment & travaux publics) pour les entreprises de construction.  
> **Transparence totale** : traçabilité de chaque action, chaque Ariary, chaque heure de chantier.

---

## Démarrage local complet (Windows / XAMPP)

Le site Web, l’API PHP et la base MySQL/MariaDB travaillent ensemble. L’application Flutter
utilise la même API ; elle ne se connecte jamais directement à la base de données.

### 1. Démarrer le backend et la base de données

Prérequis : Git, XAMPP avec PHP 8.2+ et MySQL/MariaDB, Composer et Flutter si vous utilisez
l’application mobile. Placez le dépôt dans `C:\xampp\htdocs\BTP_ERP`, puis démarrez **Apache**
et **MySQL** depuis le panneau XAMPP.

Dans PowerShell, à la racine du dépôt, initialisez la configuration et les dépendances PHP :

```powershell
if (-not (Test-Path .env)) { Copy-Item .env.example .env }
composer install
```

Ouvrez `.env` et vérifiez les paramètres de base de données (`DB_HOST`, `DB_PORT`, `DB_NAME`,
`DB_USER`, `DB_PASS`). La configuration XAMPP courante est `127.0.0.1`, `3306`, `btp_erp`,
`root` et un mot de passe vide. La commande de migration crée la base si l’utilisateur MySQL
en a le droit ; sinon, créez `btp_erp` dans phpMyAdmin avant de continuer.

Appliquez le schéma versionné et créez un compte directeur local :

```powershell
C:\xampp\php\php.exe cli.php migrate
C:\xampp\php\php.exe cli.php seed
```

`seed` crée un compte de démonstration et demande de changer son mot de passe à la première
connexion. Pour un compte personnel, utilisez plutôt
`C:\xampp\php\php.exe cli.php creer-admin admin@entreprise.mg "Nom Administrateur" "MotDePasseFort-ici" directeur`
(remplacez ces valeurs par les vôtres).

Le frontend Web est servi par Apache avec le backend PHP : aucun serveur Web séparé n’est
nécessaire. Ouvrez [http://localhost/BTP_ERP/](http://localhost/BTP_ERP/) et vérifiez la
connexion API à [http://localhost/BTP_ERP/api/v1/health](http://localhost/BTP_ERP/api/v1/health).

### 2. Lancer l’application mobile Flutter

Dans un second terminal PowerShell :

```powershell
Set-Location C:\xampp\htdocs\BTP_ERP\mobile_app
flutter pub get
flutter run -d chrome
```

Pour Android, démarrez un émulateur puis lancez `flutter run`. L’adresse API par défaut est
`http://localhost/BTP_ERP/api/v1` dans Chrome et
`http://10.0.2.2/BTP_ERP/api/v1` dans l’émulateur Android (`10.0.2.2` désigne le PC hôte).
Pour un téléphone physique connecté au même réseau, utilisez l’adresse IP locale du PC et
autorisez Apache dans le pare-feu Windows :

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.25/BTP_ERP/api/v1
```

Remplacez `192.168.1.25` par l’adresse IPv4 réelle du PC (visible avec `ipconfig`). L’application
doit pouvoir joindre cette URL depuis l’appareil. En production, utilisez une API accessible
en HTTPS et construisez avec le même paramètre `API_BASE_URL`.

### 3. Configurer les e-mails et les SMS Orange (facultatif)

Ces envois sont exécutés par le backend PHP. Renseignez les paramètres SMTP (`MAIL_HOST`,
`MAIL_PORT`, `MAIL_USERNAME`, `MAIL_PASSWORD`, `MAIL_ENCRYPTION`, `MAIL_FROM`) dans le fichier
`.env` pour l’e-mail. Pour les SMS Orange, activez `NOTIFICATION_SMS_ENABLED=true` et
renseignez `ORANGE_CLIENT_ID`, `ORANGE_CLIENT_SECRET` et `ORANGE_SENDER_ADDRESS`. Ne placez
jamais ces secrets dans l’application Flutter ou dans le dépôt.

L’écran mobile affiche les notifications enregistrées dans l’ERP. Les notifications push
Firebase qui s’affichent lorsque l’application est fermée ne sont pas configurées dans cette
version.

## 📋 Présentation du projet

### Contexte

Digital Chantier est un ERP (Enterprise Resource Planning) web développé pour les entreprises de construction et travaux publics basées à Madagascar. Il permet une gestion centralisée et transparente de tous les aspects opérationnels d'un chantier : depuis la planification budgétaire jusqu'au suivi financier, en passant par la gestion des ressources humaines, des stocks et des approvisionnements.

### Objectifs

✅ **Centraliser l'information** : Toutes les données des chantiers accessibles en un seul endroit  
✅ **Traçabilité totale** : Chaque action, chaque dépense, chaque heure travaillée est enregistrée  
✅ **Optimiser les coûts** : Suivi budgétaire en temps réel, alertes de dépassement  
✅ **Faciliter la prise de décision** : Tableaux de bord et KPIs pour les dirigeants  
✅ **Mobilité** : Site Web adaptatif et application mobile Flutter connectés à la même API  

### Public cible

- **Directeurs** : Vue d'ensemble, pilotage stratégique, validation des décisions importantes
- **Chefs de chantier** : Gestion opérationnelle quotidienne, planification, ressources
- **Comptables** : Suivi financier, facturation, rapports, conformité
- **Magasiniers** : Gestion des stocks, approvisionnements, matériaux

---

## 🎯 Fonctionnalités principales

### 1. Gestion des utilisateurs et rôles
- Authentification sécurisée avec JWT
- 4 rôles hiérarchiques : Directeur, Chef de chantier, Comptable, Magasinier
- Permissions granulaires par module et par action
- Mot de passe oublié avec envoi OTP par email

### 2. Référentiels
- **Employés** : Gestion du personnel, taux journaliers, postes
- **Clients** : Base clients, contacts, NIF/STAT
- **Fournisseurs** : Catalogue fournisseurs, catégories, évaluations
- **Engins** : Parc matériel, suivi d'état, coûts horaires
- **Matériaux** : Catalogue matériaux, prix unitaires, seuils d'alerte stock

### 3. Chantiers et lots
- Création de chantiers (bâtiment, route, autres)
- Gestion des lots par chantier avec budgets individuels
- Suivi de l'avancement pondéré par budget
- Statuts : planifié, en cours, suspendu, terminé, annulé
- Affectation de responsables et équipes

### 4. Pointage et main d'œuvre
- Feuilles de pointage journalières par chantier
- Calcul automatique des coûts de main d'œuvre
- Suivi des présences (libellés bilingues français/malgache)
- Historique des pointages avec traçabilité

### 5. Achats et stock
- Demande d'achat avec workflow de validation
- Réception et mise en stock
- Mouvements de stock (entrées/sorties)
- Alertes de stock bas (seuils configurables)
- Valorisation automatique des sorties

### 6. Demandes de matériel
- Création de demandes par le chef de chantier
- Validation par le magasinier
- Suivi de l'urgence et du statut
- Historique des demandes

### 7. Rapports journaliers
- Rapports quotidiens de chantier
- Suivi des travaux réalisés
- Signalement des problèmes rencontrés
- Observations et météo

### 8. Dépenses
- Saisie des dépenses opérationnelles
- Workflow de validation (chef chantier → comptable)
- Catégorisation par chantier et type
- Suivi du budget consommé

### 9. Budgets
- Enveloppes budgétaires par chantier et année
- Lignes budgétaires par rubrique
- Suivi en temps réel : prévu vs engagé vs réel
- Alertes de dépassement (70%, 80%, 90%, 100%)
- Clôture des budgets en fin de période

### 10. Qualité / Sécurité / Incidents
- **RFI (Request for Information)** : Demandes d'information
- **Qualité** : Inspections et contrôles qualité
- **Sécurité** : Observations et rapports de sécurité
- **Incidents** : Signalement et suivi des incidents

### 11. Facturation et devis
- Création de devis avec lignes de produits/services
- Conversion automatique devis → facture
- Gestion des paiements
- Suivi des statuts (brouillon, envoyé, accepté, payé, etc.)
- Impression des factures et reçus de paiement

### 12. Suivi financier
- Tableau de bord avec KPIs financiers
- Rentabilité par chantier
- Trésorerie (encaissements vs décaissements)
- Rapports mensuels

### 13. Notifications
- Notifications enregistrées dans l’ERP et consultables sur le Web et dans l’application Flutter
- Alertes de stock, factures impayées, devis en attente
- Marquage comme lu/non lu
- Badge de notification dans le header

### 14. Journal d'audit
- Traçabilité complète de toutes les actions
- Qui a fait quoi, quand, depuis quelle IP
- Indispensable pour la conformité et la sécurité

---

## 🏗️ Architecture technique

## 🏗️ Architecture technique

### Stack technique

- **Backend** : PHP 8.2+ pur, architecture MVC maison légère (pas de framework)
- **Base de données** : MySQL 8 / MariaDB (SQL portable)
- **Frontend** : HTML5 / CSS3 / JavaScript vanilla, pages servies par PHP + appels `fetch` vers l'API
- **API** : REST JSON sous `/api/v1/`, sécurisée par JWT et partagée entre le site Web et l’application Flutter
- **Auth** : JWT HS256 fait maison (access + refresh)
- **E-mail** : PHPMailer via SMTP authentifié pour les codes OTP
- **Hébergement cible** : Simafri (mutualisé) — tout tourne en PHP/MySQL, tâches planifiées via cron cPanel

## 📊 Architecture du système

### Principes de conception

- **Séparation API/Web** : L'API REST alimente le frontend web et le futur mobile
- **Stateless** : Authentification JWT sans sessions serveur
- **RBAC** : Contrôle d'accès basé sur les rôles (4 rôles)
- **Audit trail** : Traçabilité complète des actions sensibles
- **Responsive** : Interface adaptée mobile/tablette/desktop

### Flux de données

```
Utilisateur → Interface Web → API (JWT) → MySQL
                     ↓
               Notifications système
```

## 🎯 Fonctionnalités détaillées

### Module 1 : Authentification & Gestion des utilisateurs
- Login sécurisé avec mot de passe
- Récupération de mot de passe par email (OTP)
- 4 rôles : Directeur, Chef de chantier, Comptable, Magasinier
- Permissions granulaires par module et action
- Journal des connexions

### Module 2 : Référentiels
Base de données structurée pour :
- **Employés** : Gestion du personnel, taux journaliers, contrats
- **Clients** : Fiche client, contacts, informations légales
- **Fournisseurs** : Catalogue, catégories, évaluations
- **Engins** : Parc matériel, maintenance, coûts horaires
- **Matériaux** : Catalogue, prix unitaires, unités de mesure

### Module 3 : Chantiers & Lots
- Création de chantiers (bâtiment, route, autres)
- Découpage en lots avec budgets individuels
- Suivi de l'avancement pondéré par budget
- Affectation de responsables et équipes
- Statuts du cycle de vie des chantiers

### Module 4 : Pointage & Main d'œuvre
- Feuilles de pointage journalières
- Suivi des présences (bilingue français/malgache)
- Calcul automatique des coûts MO
- Historique par employé et par chantier

### Module 5 : Achats & Stock
- Workflow demande → validation → réception → stock
- Mouvements de stock (entrées/sorties)
- Alertes de stock bas
- Valorisation automatique des consommations

### Module 6 : Demandes de matériel
- Demandes créées par le chef de chantier
- Validation par le magasinier
- Suivi de l'urgence et du statut
- Historique des demandes

### Module 7 : Rapports journaliers
- Rapports quotidiens de chantier
- Travaux réalisés, problèmes rencontrés
- Observations et conditions météo
- Soumission et consultation

### Module 8 : Dépenses
- Saisie des dépenses opérationnelles
- Workflow de validation
- Rattachement aux budgets
- Suivi du budget consommé

### Module 9 : Budgets
- Enveloppes budgétaires par chantier/année
- Lignes budgétaires par rubrique
- Suivi prévu vs engagé vs réel
- Alertes de dépassement (70%, 80%, 90%, 100%)
- Clôture des budgets

### Module 10 : Qualité / Sécurité / Incidents
- **RFI** : Demandes d'information et clarifications
- **Qualité** : Inspections et contrôles qualité
- **Sécurité** : Rapports et observations de sécurité
- **Incidents** : Signalement et suivi des incidents

### Module 11 : Facturation & Devis
- Création de devis avec lignes produits/services
- Conversion automatique devis → facture
- Gestion des paiements et encaissements
- Impression des factures et reçus
- Suivi des statuts et relances

### Module 12 : Suivi financier
- Tableau de bord avec KPIs financiers
- Rentabilité par chantier
- Trésorerie (encaissements vs décaissements)
- Rapports mensuels et export

### Module 13 : Notifications
- Notifications enregistrées dans l’ERP et consultables sur le Web et dans l’application Flutter
- Alertes de stock, factures impayées, devis en attente
- Badge de notification dans le header
- Marquage comme lu/non lu

### Module 14 : Journal d'audit
- Traçabilité complète de toutes les actions
- Qui a fait quoi, quand, depuis quelle IP
- Export possible pour analyse

---

## 🏗️ Architecture technique

- **Backend** : PHP 8.2+ pur, architecture MVC maison légère (pas de framework)
- **Base de données** : MySQL 8 / MariaDB (SQL portable)
- **Frontend** : HTML5 / CSS3 / JavaScript vanilla, pages servies par PHP + appels `fetch` vers l'API
- **API** : REST JSON sous `/api/v1/`, sécurisée par JWT et partagée entre le site Web et l’application Flutter
- **Auth** : JWT HS256 fait maison (access + refresh)
- **E-mail** : PHPMailer via SMTP authentifié pour les codes OTP
- **Hébergement cible** : Simafri (mutualisé) — tout tourne en PHP/MySQL, tâches planifiées via cron cPanel

### Architecture MVC maison

L'application utilise une architecture MVC custom légère, optimisée pour la performance et la simplicité :

```
┌─────────────────────────────────────────────┐
│           index.php (Front Controller)       │
│              ↓                                │
│         Router (analyse URL)                │
│              ↓                                │
│    ┌──────────────────────────┐          │
│    │  Middleware (Auth, RBAC) │          │
│    └──────────────────────────┘          │
│              ↓                                │
│         Controller (traitement logique)    │
│              ↓                                │
│    ┌──────────────────────────┐          │
│    │  Model (accès BDD)      │          │
│    └──────────────────────────┘          │
│              ↓                                │
│         View (rendu HTML)                 │
└─────────────────────────────────────────────┘
```

### Principes de conception

- **Séparation des responsabilités** : API (JSON) vs Web (HTML)
- **Source unique de vérité** : L'API alimente le web et le futur mobile
- **Sécurité par défaut** : Toutes les routes API sont protégées par défaut
- **Traçabilité** : Journal d'audit sur chaque action sensible
- **Performance** : Requêtes optimisées, indexation BDD, cache judicieux

---

## 🗄️ Base de données

### Schéma relationnel

```
utilisateurs ←→ chantiers ←→ lots
      ↓            ↓          ↓
  notifications   pointages   demandes_materiel
      ↓            ↓          ↓
  referentiels   depenses   rapports_journaliers
      ↓            ↓          ↓
  budgets      achats     rfi/qualite/securite/incidents
      ↓            ↓
    stock     factures
      ↓            ↓
  mouvements_stock  paiements
```

### Migrations

Le système utilise des migrations SQL versionnées dans `database/migrations/` :
- `0001_socle.sql` : Tables utilisateurs, notifications, journal d'audit
- `0002_utilisateurs.sql` : Gestion des rôles et permissions
- `0003_referentiels.sql` : Employés, clients, fournisseurs, engins, matériaux
- `0004_chantiers.sql` : Chantiers et lots
- `0005_pointages.sql` : Feuilles de pointage
- `0006_achats_stock.sql` : Achats, stock, mouvements
- `0007_facturation.sql` : Devis, factures, paiements
- `0008_montants_bigint.sql` : Migration vers BIGINT pour les montants
- `0009_reinitialisation_mot_de_passe.sql` : Système de reset MDP
- `0010_demande_materiel_rapport_depenses.sql` : Fonctionnalités avancées

### Caractéristiques techniques

- **Moteur** : InnoDB (transactions, clés étrangères)
- **Encodage** : UTF8MB4 (support caractères malgaches)
- **Montants** : BIGINT (gère les milliards d'Ariary)
- **Indexation** : Index sur les clés étrangères et champs de recherche fréquents
- **Audit** : Table `journal_audit` avec timestamps et utilisateur

---

## 🔐 Sécurité

### Authentification

- **JWT (JSON Web Tokens)** : Authentification stateless
- **Access token** : Durée courte (configurable, défaut 1h)
- **Refresh token** : Stocké en cookie httpOnly sécurisé
- **Mot de passe oublié** : OTP à 6 chiffres envoyé par email (valide 15 min)

### Autorisations (RBAC)

Matrice de permissions par rôle :

| Module | Directeur | Chef chantier | Comptable | Magasinier |
|--------|-----------|---------------|-----------|------------|
| Tableau de bord | ✅ | ✅ | ✅ | ✅ |
| Chantiers | ✅ ✅ ✅ ✅ | ✅ ✅ | ✅ | ✅ |
| Lots | ✅ ✅ ✅ ✅ | ✅ ✅ ✅ ✅ | ✅ | ✅ |
| Pointages | ✅ ✅ | ✅ ✅ | ✅ | ✅ |
| Finances | ✅ | ✅ | ✅ ✅ ✅ | ❌ |
| Achats | ✅ | ✅ | ❌ | ✅ ✅ ✅ |
| Stock | ✅ | ✅ | ✅ | ✅ ✅ ✅ |
| Devis | ✅ | ✅ | ✅ ✅ ✅ | ❌ |
| Factures | ✅ | ✅ | ✅ ✅ ✅ | ❌ |
| Budgets | ✅ ✅ ✅ | ✅ | ✅ ✅ | ❌ |
| Dépenses | ✅ | ✅ ✅ | ✅ ✅ ✅ | ✅ |
| Demandes matériel | ✅ | ✅ ✅ | ✅ | ✅ ✅ ✅ |
| Rapports journaliers | ✅ | ✅ ✅ ✅ | ✅ | ✅ |
| RFI/Qualité/Sécurité/Incidents | ✅ | ✅ ✅ ✅ | ✅ | ❌ |
| Notifications | ✅ | ✅ | ✅ | ✅ |
| Journal d'audit | ✅ | ❌ | ❌ | ❌ |
| Paramètres | ✅ | ❌ | ❌ | ❌ |

**Légende** : ✅ = View, ✅ ✅ = View + Create, ✅ ✅ ✅ = View + Create + Edit, ✅ ✅ ✅ ✅ = Full access

### Protection des données

- **Masquage côté serveur** : Filtre SQL selon le rôle (pas juste UI)
- **Validation des entrées** : Sanitization et typage strict
- **Protection CSRF** : Tokens sur les formulaires sensibles
- **CORS configuré** : Origines autorisées configurables
- **.htaccess** : Protection des dossiers sensibles (app/, database/, storage/, routes/)

### Audit et traçabilité

- **Journal d'audit** : Chaque action créative/modificative est loguée
- **Informations enregistrées** : Utilisateur, date, IP, action, entité, ancien/nouveau
- **Consultation** : Export JSON possible pour analyse forensique

---

## 🚀 Installation et déploiement

## Arborescence

```
BTP_ERP/
├── index.php               ← front controller unique et racine web
├── .htaccess               ← réécriture d'URL
├── assets/                  ← css, js, images téléversées
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

Chaque développeur peut utiliser sa propre base locale. Les migrations créent le schéma
identique sur chaque poste ; il n'est pas nécessaire de s'envoyer un export SQL. Les données
de démonstration sont facultatives et ne doivent pas contenir de données réelles ou sensibles.

### Sur Windows

1. Installer Git, XAMPP (PHP 8.2+ et MySQL/MariaDB) et Composer.
2. Cloner le dépôt dans `C:\xampp\htdocs\BTP_ERP` :
   ```bash
   git clone <URL_DU_DEPOT_GITHUB> C:\xampp\htdocs\BTP_ERP
   ```
3. Démarrer Apache et MySQL dans XAMPP, puis ouvrir PowerShell dans le dossier du projet.
4. Créer la configuration locale et installer les dépendances :
   ```powershell
   Copy-Item .env.example .env
   composer install
   ```
5. Vérifier dans `.env` les paramètres `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER` et `DB_PASS`.
   Pour la configuration XAMPP locale par défaut, ils sont généralement `127.0.0.1`, `3306`,
   `btp_erp`, `root` et un mot de passe vide. Le compte MySQL doit pouvoir créer la base ;
   sinon, créez `btp_erp` dans phpMyAdmin avant de lancer les migrations.
6. Appliquer les migrations et créer le compte de démonstration :
   ```powershell
   php cli.php migrate
   php cli.php seed
   ```
   Si `php` n'est pas dans le `PATH`, utilisez `C:\xampp\php\php.exe` à la place de `php`.
   Pour charger aussi les données métier de démonstration, lancez `php cli.php demo`.
7. Ouvrir **http://localhost/BTP_ERP/** dans le navigateur.

### Générer le paquet desktop Windows (PHP Desktop)

Le paquet desktop réutilise les mêmes pages PHP dans une fenêtre Windows. Le runtime PHP
Desktop embarque PHP 8.3 et son navigateur ; MySQL reste fourni par XAMPP et doit tourner
localement sur le PC. Ce paquet de développement n'est pas un installateur et ne partage pas
automatiquement les bases de données entre ordinateurs.

Depuis PowerShell, à la racine du dépôt, avec MySQL XAMPP démarré et Composer
installé, générez le paquet et initialisez la base locale de démonstration :

```powershell
.\desktop\build.ps1 -RunMigrations
```

Le script télécharge PHP Desktop Chrome 130.1 depuis sa publication officielle, assemble les
fichiers nécessaires sans reprendre votre `.env` local, les journaux, les fichiers téléversés ni
l'export SQL. Il génère une configuration `.env` depuis `.env.example`, installe les dépendances
Composer, active les extensions PHP requises par les vues et applique les migrations. Il crée le paquet dans un nouveau dossier
`desktop\build\DigitalChantier-<date>` ; ces fichiers générés sont exclus de Git. Le compte de
démonstration est `directeur@digitalchantier.mg` / `Directeur@2026` (à changer après connexion).
Pour construire sans toucher à la base, omettez `-RunMigrations`, puis adaptez le fichier
`.env` du paquet et lancez ses migrations manuellement avec le `php.exe` embarqué.

Lancez `phpdesktop-chrome.exe` à la racine du paquet : en mode desktop, l'ouverture de la
racine redirige directement vers l'écran de connexion. Chaque développeur doit générer son
propre paquet et garde sa propre configuration `.env` et sa base locale. Le runtime est
volumineux et n'est pas versionné dans Git ; le collègue clone le dépôt puis exécute le même
script sur son PC Windows 10 ou supérieur.
Le serveur local PHP Desktop traite mal les requêtes `PUT`, `PATCH` et `DELETE` ; le client
desktop les envoie donc en `POST` avec `X-HTTP-Method-Override`. Cette surcharge n'est activée
que lorsque `APP_DESKTOP=true` et ne change pas les requêtes de l'application web.

### Vérifier l'API directement

```bash
curl http://localhost/BTP_ERP/api/v1/health
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

Les notifications applicatives déjà créées dans la cloche sont également envoyées par e-mail. Pour les SMS, créez une application Orange Developer avec l'API SMS activée pour le pays concerné, puis renseignez dans le `.env` privé `ORANGE_CLIENT_ID`, `ORANGE_CLIENT_SECRET` et `ORANGE_SENDER_ADDRESS` (numéro expéditeur autorisé, au format international, par exemple `+261...`). Activez ensuite `NOTIFICATION_SMS_ENABLED=true`. L'application utilise OAuth Orange pour obtenir le jeton d'accès puis appelle l'API SMS Orange. Les numéros locaux commençant par `0` sont convertis avec `ORANGE_DEFAULT_COUNTRY_CODE` (indicatif par défaut : `261`) ; les autres numéros doivent être au format international `+...`. `NOTIFICATION_EMAIL_ENABLED` vaut `true` par défaut et `NOTIFICATION_SMS_ENABLED` vaut `false` tant que le fournisseur n'est pas configuré. Ne mettez jamais les identifiants Orange dans le dépôt ou dans un message.

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

---

## 📚 Glossaire des termes BTP

### Termes techniques

- **Chantier** : Site de construction où s'effectuent les travaux
- **Lot** : Partie d'un chantier divisée par spécialité (gros œuvre, second œuvre, VRD, etc.)
- **Avancement** : Pourcentage de complétion d'un lot ou d'un chantier
- **Budget prévisionnel** : Montant estimé pour réaliser un chantier
- **Budget révisé** : Budget ajusté en cours de projet
- **Pointage** : Enregistrement des heures travaillées par le personnel
- **Taux journalier** : Coût journalier d'un employé
- **RFI (Request for Information)** : Demande d'information formelle
- **Gros œuvre** : Structure de base d'un bâtiment (fondations, murs porteurs)
- **Second œuvre** : Finitions (plomberie, électricité, peinture)
- **VRD (Voirie et Réseaux Divers)** : Travaux d'aménagement extérieur

### Termes financiers

- **Devis** : Document estimatif des coûts avant travaux
- **Facture** : Document de demande de paiement
- **TTC (Toutes Taxes Comprises)** : Prix incluant la TVA
- **HT (Hors Taxes)** : Prix sans TVA
- **TVA (Taxe sur la Valeur Ajoutée)** : Impôt sur la consommation
- **NIF (Numéro d'Identification Fiscale)** : Identifiant fiscal
- **STAT (Statistique)** : Identifiant statistique à Madagascar

### Termes de gestion

- **Stock** : Ensemble des matériaux et équipements disponibles
- **Mouvement de stock** : Entrée ou sortie de stock
- **Seuil d'alerte** : Niveau minimum de stock déclenchant une alerte
- **Consommation** : Utilisation effective des ressources
- **Dépassement** : Utilisation au-delà du budget prévu
- **Engagement** : Dépense validée mais non encore payée

---

## 🔧 Maintenance et support

### Sauvegardes de données

```bash
# Sauvegarde manuelle de la base
php cli.php sauvegarde

# La sauvegarde est stockée dans storage/backups/
# Format : backup_YYYY-MM-DD_HHMMSS.sql
```

### Mises à jour

1. Tirer les dernières modifications du dépôt
2. Appliquer les nouvelles migrations : `php cli.php migrate`
3. Vider le cache : `php cli.php cache-clear`
4. Tester en environnement de staging avant production

### Résolution de problèmes

| Problème | Solution |
|----------|----------|
| Erreur de connexion BDD | Vérifier `.env` (DB_HOST, DB_NAME, DB_USER, DB_PASS) |
| Erreur 500 sur les pages | Vérifier `storage/logs/app.log` |
| Emails non envoyés | Vérifier configuration SMTP dans `.env` et logs |
| Token JWT expiré | Rafraîchir la page ou se reconnecter |
| Permissions refusées | Vérifier le rôle de l'utilisateur dans `utilisateurs` table |

### Performance

- **Optimisation des requêtes** : Index sur les champs de recherche fréquents
- **Pagination** : Limite par défaut 50 éléments, configurable
- **Cache** : Cache PHP côté serveur pour les données peu volatiles
- **Compression** : gzip activé via `.htaccess`

---

## 🚀 Roadmap future

### Version 2.0 (Planifiée)

- [ ] Application mobile React Native (iOS et Android)
- [ ] Mode offline avec synchronisation
- [ ] Notifications push
- [ ] Géolocalisation des chantiers
- [ ] Photos et documents attachés aux chantiers
- [ ] Signature électronique des documents
- [ ] Export PDF automatique des rapports
- [ ] Graphiques avancés (Chart.js)
- [ ] Planification de ressources (Gantt)
- [ ] Module CRM (gestion des relations clients)

### Version 3.0 (Futur)

- [ ] Intégration comptable (logiciel comptable tiers)
- [ ] Prévisionnel financier à moyen terme
- [ ] Analyse prédictive des coûts
- [ ] Module plannings et calendriers
- [ ] Gestion des sous-traitants
- [ ] Tableaux de bord personnalisables
- [ ] API publique pour intégrations tierces
- [ ] Webhooks pour événements automatiques

---

## 📄 Licence et crédits

### Licence

Ce projet est propriétaire et développé pour Digital Chantier. Tous droits réservés.

### Technologies utilisées

- **PHP 8.2+** : Langage backend
- **MySQL/MariaDB** : Base de données relationnelle
- **Composer** : Gestion des dépendances PHP
- **PHPMailer** : Envoi d'emails
- **JWT** : Authentification sécurisée

### Remerciements

- L'équipe de développement Digital Chantier
- La communauté PHP pour les excellentes ressources
- Simafri pour l'hébergement mutualisé

---

## 📞 Contact et support

### Support technique

- **Email** : support@digitalchantier.mg
- **Documentation** : docs.digitalchantier.mg
- **Issue tracker** : Interne (GitHub/GitLab privé)

### Signalement de bugs

Pour signaler un bug ou proposer une amélioration :
1. Vérifier que le problème n'existe pas déjà
2. Décrire le problème de manière détaillée
3. Fournir les étapes pour reproduire
4. Inclure les logs pertinents (si applicables)
5. Indiquer l'environnement (PHP version, MySQL version, OS)

---

## 🎯 Cas d'usage

### Cas 1 : Création d'un nouveau chantier

1. Le directeur crée un nouveau chantier
2. Il définit le budget prévisionnel global
3. Il crée les lots (gros œuvre, second œuvre, etc.)
4. Il affecte un chef de chantier responsable
5. Le chef de chantier commence la planification

### Cas 2 : Suivi des dépenses

1. Le chef de chantier crée une demande de matériel
2. Le magasinier valide et traite la demande
3. Le comptable saisit les dépenses réelles
4. Le système met à jour le budget consommé
5. Le directeur voit l'alerte si dépassement

### Cas 3 : Facturation client

1. Le comptable crée un devis pour un client
2. Le devis est envoyé au client
3. Le client accepte le devis
4. Le comptable convertit le devis en facture
5. Le paiement est enregistré
6. Le solde est mis à jour

### Cas 4 : Gestion de stock

1. Le magasinier surveille les niveaux de stock
2. Le système envoie une alerte si stock bas
3. Le magasinier crée une demande d'achat
4. Le directeur valide l'achat
5. Le fournisseur livre les matériaux
6. Le stock est mis à jour automatiquement

---

## 🌐 Adaptation locale

### Madagascar

L'application est conçue pour le contexte malgache :
- **Devise** : Ariary (MGA)
- **Langue** : Français (interface) + Malgache (terrain)
- **Fiscalité** : NIF/STAT pour les entreprises
- **Réglementation** : Conforme aux normes BTP locales

### Internationalisation

Pour adapter à un autre pays :
1. Modifier la devise dans `.env` et la base de données
2. Traduire les termes malgaches si nécessaire
3. Adapter les règles fiscales locales
4. Modifier les formats de date et de nombre

---

## 🎓 Formation des utilisateurs

### Modules de formation

1. **Module 1 : Introduction à Digital Chantier** (30 min)
   - Présentation de l'interface
   - Navigation principale
   - Concepts de base

2. **Module 2 : Gestion des chantiers** (1h)
   - Création d'un chantier
   - Gestion des lots
   - Suivi de l'avancement

3. **Module 3 : Pointage et main d'œuvre** (45 min)
   - Saisie des pointages
   - Calcul des coûts
   - Rapports

4. **Module 4 : Stock et achats** (1h)
   - Gestion du stock
   - Demandes d'achat
   - Réception et validation

5. **Module 5 : Budgets et finances** (1h30)
   - Création de budgets
   - Suivi des dépenses
   - Rapports financiers

6. **Module 6 : Facturation** (1h)
   - Création de devis
   - Conversion en facture
   - Gestion des paiements

### Supports de formation

- **Manuels utilisateur** : PDF téléchargeables
- **Vidéos tutorielles** : Captures d'écran commentées
- **FAQ** : Questions fréquentes
- **Support en ligne** : Chat ou email

---

## 📊 Statistiques du projet

- **Lignes de code** : ~25,000 lignes PHP + ~5,000 lignes JavaScript
- **Tables de base de données** : 20+ tables
- **Endpoints API** : 50+ endpoints REST
- **Modules fonctionnels** : 14 modules
- **Rôles utilisateurs** : 4 rôles
- **Langues supportées** : Français + Malgache (terrain)
- **Temps de développement** : Ongoing
- **Dernière mise à jour** : 2026

---

## ✅ Checklist de déploiement

### Pré-déploiement

- [ ] Code revu et testé
- [ ] Tests passés (unitaires, intégration)
- [ ] Documentation à jour
- [ ] Migration SQL prête
- [ ] Backup de l'ancienne version effectué

### Déploiement

- [ ] Mise en maintenance du site
- [ ] Application des migrations
- [ ] Mise à jour des dépendances Composer
- [ ] Nettoyage du cache
- [ ] Vérification des logs
- [ ] Tests de smoke testing

### Post-déploiement

- [ ] Vérification de toutes les fonctionnalités
- [ ] Test des connexions utilisateurs
- [ ] Vérification des emails
- [ ] Surveillance des logs (24h)
- [ ] Communication aux utilisateurs
- [ ] Documenter les changements

---

## 🎉 Conclusion

Digital Chantier est une solution ERP complète et professionnelle pour la gestion de chantiers BTP. Conçue pour le contexte malgache mais adaptable à d'autres pays, elle offre une visibilité totale sur les opérations, les coûts et la rentabilité.

Grâce à son architecture modulaire, son système de permissions granulaire et son journal d'audit complet, Digital Chantier permet aux entreprises de construction de :
- ✅ Améliorer leur rentabilité
- ✅ Réduire les erreurs et les pertes
- ✅ Optimiser l'utilisation des ressources
- ✅ Prendre des décisions éclairées
- ✅ Garantir la conformité et la traçabilité

Pour plus d'informations, consultez la documentation ou contactez l'équipe support.

---

**Digital Chantier — ERP BTP**  
© 2026 Digital Chantier. Tous droits réservés.
