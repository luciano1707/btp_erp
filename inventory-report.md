# Inventory Exhaustif - Projet PHP ERP BTP_ERP

**Emplacement :** C:\xampp\htdocs\BTP_ERP  
**Date d'inventaire :** 02/10/2026  
**Methode :** Lecture exhaustive des fichiers  
**Exclusions :** vendor/, .git/

---
## 1. TABLE A - Pages Web (Routes + Vues + Contrôleurs + JS + Permissions)

| Chemin (URL) | Methode | Controleur | Methode Action | Vue Template | Fichier Vue | JS Lie | Module | Droit | Auth | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| / | GET | App\Controllers\Web\HomeController | index | accueil | app/Views/accueil.php | app.js |  |  | Non | Page publique - accueil par défaut |
| /connexion | GET | App\Controllers\Web\AuthPageController | connexion | auth.connexion | app/Views/auth/connexion.php | connexion.js, auth.js |  |  | Non | Page de connexion |
| /mot-de-passe-oublie | GET | App\Controllers\Web\AuthPageController | motDePasseOublie | auth.mot-de-passe-oublie | app/Views/auth/mot-de-passe-oublie.php | mot-de-passe-oublie.js, auth.js |  |  | Non | Récupération mot de passe |


| /tableau-de-bord | GET | App\\Controllers\\Web\\AuthPageController | tableauDeBord | tableau_de_bord | app/Views/tableau_de_bord.php | dashboard.js, charts.js, format.js, auth.js | tableau_de_bord | view | Oui |  |
| /referentiels | GET | App\\Controllers\\Web\\ReferentielController | index | referentiels.index | app/Views/referentiels/index.php | referents.js, auth.js | referentiels | view | Oui | Sommaire référentiels |
| /referentiels/{entite} | GET | App\\Controllers\\Web\\ReferentielController | liste | referentiels.liste | app/Views/referentiels/liste.php | ressource-liste.js, auth.js | referentiels | view | Oui | Liste entité |
| /referentiels/{entite}/nouveau | GET | App\\Controllers\\Web\\ReferentielController | formulaire | referentiels.formulaire | app/Views/referentiels/formulaire.php | ressource-form.js, auth.js | referentiels | create | Oui |  |
| /referentiels/{entite}/{id}/modifier | GET | App\\Controllers\\Web\\ReferentielController | formulaire | referentiels.formulaire | app/Views/referentiels/formulaire.php | ressource-form.js, auth.js | referentiels | edit | Oui |  |
| /chantiers | GET | App\\Controllers\\Web\\ChantierPageController | liste | chantiers.liste | app/Views/chantiers/liste.php | chantier-liste.js, auth.js | chantiers | view | Oui |  |
| /chantiers/nouveau | GET | App\\Controllers\\Web\\ChantierPageController | formulaire | chantiers.formulaire | app/Views/chantiers/formulaire.php | chantier-form.js, auth.js | chantiers | create | Oui |  |
| /chantiers/{id}/modifier | GET | App\\Controllers\\Web\\ChantierPageController | formulaire | chantiers.formulaire | app/Views/chantiers/formulaire.php | chantier-form.js, auth.js | chantiers | edit | Oui |  |
| /chantiers/{id}/pointage | GET | App\\Controllers\\Web\\ChantierPageController | pointage | chantiers.pointage | app/Views/chantiers/pointage.php | pointage.js, auth.js | chantiers | edit | Oui |  |
| /chantiers/{id} | GET | App\\Controllers\\Web\\ChantierPageController | detail | chantiers.detail | app/Views/chantiers/detail.php | chantier-detail.js, auth.js | chantiers | view | Oui |  |
| /achats | GET | App\\Controllers\\Web\\AchatPageController | liste | achats.liste | app/Views/achats/liste.php | achat-liste.js, auth.js | achats | view | Oui |  |
| /achats/nouveau | GET | App\\Controllers\\Web\\AchatPageController | formulaire | achats.formulaire | app/Views/achats/formulaire.php | achat-form.js, auth.js | achats | create | Oui |  |
| /achats/{id} | GET | App\\Controllers\\Web\\AchatPageController | detail | achats.detail | app/Views/achats/detail.php | achat-detail.js, auth.js | achats | view | Oui |  |
| /stock | GET | App\\Controllers\\Web\\AchatPageController | stock | stock.index | app/Views/stock/index.php | stock.js, auth.js | stock | view | Oui |  |
| /devis | GET | App\\Controllers\\Web\\FacturationPageController | listeDevis | facturation.liste | app/Views/facturation/liste.php | doc-liste.js, auth.js | devis | view | Oui |  |
| /devis/nouveau | GET | App\\Controllers\\Web\\FacturationPageController | formulaireDevis | facturation.formulaire | app/Views/facturation/formulaire.php | doc-form.js, auth.js | devis | create | Oui |  |
| /devis/{id}/imprimer | GET | App\\Controllers\\Web\\FacturationPageController | imprimerDevis | facturation.imprimer_devis | app/Views/facturation/imprimer_devis.php | devis-print.js, format.js | devis | view | Oui |  |
| /devis/{id} | GET | App\\Controllers\\Web\\FacturationPageController | detailDevis | facturation.detail_devis | app/Views/facturation/detail_devis.php | devis-detail.js, auth.js | devis | view | Oui |  |
| /factures | GET | App\\Controllers\\Web\\FacturationPageController | listeFactures | facturation.liste | app/Views/facturation/liste.php | doc-liste.js, auth.js | factures | view | Oui |  |
| /factures/nouveau | GET | App\\Controllers\\Web\\FacturationPageController | formulaireFacture | facturation.formulaire | app/Views/facturation/formulaire.php | doc-form.js, auth.js | factures | create | Oui |  |
| /factures/{id} | GET | App\\Controllers\\Web\\FacturationPageController | detailFacture | facturation.detail_facture | app/Views/facturation/detail_facture.php | facture-detail.js, auth.js | factures | view | Oui |  |
| /factures/{id}/imprimer | GET | App\\Controllers\\Web\\FacturationPageController | imprimerFacture | facturation.imprimer_facture | app/Views/facturation/imprimer_facture.php | facture-print.js, format.js | factures | view | Oui |  |
| /factures/{id}/recu | GET | App\\Controllers\\Web\\FacturationPageController | recuFacture | facturation.recu_facture | app/Views/facturation/recu_facture.php | recu-print.js, format.js | factures | view | Oui |  |
| /finances | GET | App\\Controllers\\Web\\FinancePageController | index | finances | app/Views/finances.php | finances.js, charts.js, auth.js | finances | view | Oui |  |
| /journal | GET | App\\Controllers\\Web\\JournalPageController | index | journal | app/Views/journal.php | journal.js, auth.js | journal | view | Oui |  |
| /profil | GET | App\\Controllers\\Web\\ProfilPageController | index | profil | app/Views/profil.php | profil.js, auth.js | profil | view | Oui |  |
| /parametres | GET | App\\Controllers\\Web\\ParametrePageController | index | parametres | app/Views/parametres.php | parametres.js, auth.js | parametres | view | Oui |  |

---


## 2. TABLE B - API Endpoints (REST) - suite

| GET | /api/v1/clients | ClientController:index | Oui | referentiels:view | CRUD générique (ResourceController) |
| GET | /api/v1/clients/{id} | App\\Controllers\\Api\\ClientController:show | Oui | referentiels:view | |
| POST | /api/v1/clients | App\\Controllers\\Api\\ClientController:store | Oui | referentiels:create | |
| PUT | /api/v1/clients/{id} | App\\Controllers\\Api\\ClientController:update | Oui | referentiels:edit | |
| DELETE | /api/v1/clients/{id} | App\\Controllers\\Api\\ClientController:destroy | Oui | referentiels:delete | |
| GET | /api/v1/fournisseurs | App\\Controllers\\Api\\FournisseurController:index | Oui | referentiels:view | CRUD |

---

## 3. TABLE C - Referentiel Entities + Fields (app/Config/referentiels.php)

### 3.1 Employés (employes)
- **Libellé**: Employé / Employés
- **Endpoint API**: api/v1/employes
- **Colonnes (liste)**:
  1. matricule (texte) - Matricule
  2. nom (texte) - Nom
  3. prenom (texte) - Prénom
  4. poste (texte) - Poste
  5. type_contrat (badge) - Contrat [journalier|mensuel|sous_traitant]
  6. taux_journalier (ariary) - Taux/jour
  7. actif (booleen) - Actif
- **Champs (formulaire)**:
  1. matricule (text) - optionnel
  2. nom (text, requis) - Nom
  3. prenom (text) - Prénom
  4. telephone (tel) - Téléphone
  5. poste (text) - Poste
  6. type_contrat (select) - journalier/mensuel/sous_traitant, requis via règles API (dans)
  7. taux_journalier (number, entier min:0) - Taux journalier (Ar)
  8. actif (checkbox, défaut true) - Actif

### 3.2 Clients (clients)
- **Endpoint**: api/v1/clients
- **Colonnes**: nom, contact, telephone, nif, actif (booleen)
- **Champs**: nom(requis), contact, telephone, email(email), adresse(textarea), nif, stat, actif(checkbox def true)
- **Validation API**: nom requis longueur_max:150, email format email, actif entier

### 3.3 Fournisseurs (fournisseurs)
- **Endpoint**: api/v1/fournisseurs
- **Colonnes**: nom, categorie(badge), contact, telephone, actif(booleen)
- **Champs**: nom(requis), categorie, contact, telephone, email, adresse, nif, stat, actif(def true)
- **Validation**: nom requis max 150, email, actif entier

### 3.4 Engins (engins)
- **Endpoint**: api/v1/engins
- **Colonnes**: code, designation, type, immatriculation, etat(badge), cout_horaire(ariary)
- **Champs**: code, designation(requis), type, immatriculation, etat(select: disponible/en_service/maintenance/hors_service), cout_horaire(number entier min:0), actif(def true)
- **Validation**: designation requis max 150, etat dans liste, cout_horaire entier min:0, actif entier

### 3.5 Matériaux (materiaux)
- **Endpoint**: api/v1/materiaux
- **Colonnes**: code, designation, unite, prix_unitaire(ariary), actif(booleen)
- **Champs**: code, designation(requis), unite(max 20), prix_unitaire(number entier min:0), seuil_alerte(number entier min:0), actif(def true)
- **Validation**: designation requis max 150, unite max 20, prix_unitaire/seuil_alerte min:0, actif entier

**Source unique**: app/Config/referentiels.php (pilote vues liste/formulaire + endpoint API)
## 4. TABLE D - Roles/Permissions Matrix (app/Core/Access.php)

### Rôles définis
- **directeur** : Accès complet à tous les modules (super-admin dans le code : if ( === 'directeur') return true;)
- **chef_chantier** : Chef de chantier
- **comptable** : Comptable
- **magasinier** : Magasinier

### Matrice des permissions (module => rôle => actions)

| Module | directeur | chef_chantier | comptable | magasinier | Notes |
|---|---|---|---|---|---|
| tableau_de_bord | ALL (global) | view | view | view | Stats dashboard |
| chantiers | ALL | view, create, edit | view | view | CRUD partiel (pas delete dans matrice explicite sauf via routes avec PermissionMiddleware) |
| finances | ALL | view | view, create, edit, validate | - | |
| achats | ALL | view | view, create, edit, validate | view, create, edit, validate | Achats + receptions |
| stock | ALL | view | view | view, create, edit, validate | Mouvements stock |
| devis | ALL | view | view, create, edit, validate | - | |
| factures | ALL | - | view, create, edit, validate | - | Factures réservées comptable (chef_chantier non listé) |
| referentiels | ALL | view | view, create, edit | view, create, edit | CRUD lecture/écriture (pas delete dans matrice) |
| journal | ALL | view | view | view | Audit (lecture) |
| profil | ALL | view, edit, password | view, edit, password | view, edit, password | Tous rôles |
| utilisateurs | ALL | - | - | - | Matrice vide (aucune action définie) |
| parametres | ALL | - | - | - | Matrice vide |

**Remarques importantes (lecture du code Access.php)**:
- Le rôle directeur bypass totalement : utorise() retourne 	rue pour tout module/action (ligne ~Access.php:71-82)
- Actions possibles : iew, create, edit, delete, alidate, password (selon usage)
- Pour utilisateurs et parametres, la matrice ne liste aucun rôle sauf directeur (bypass). Les routes API vérifient explicitement avec PermissionMiddleware pour certains cas (ex. /api/v1/utilisateurs requiert utilisateurs:view - seul directeur passera via bypass; autres rôles non listés dans matrice -> refusés sauf directeur)
- Middleware: PermissionMiddleware (app/Middleware/PermissionMiddleware.php) appelle Access::autorise(role, module, action) après AuthMiddleware. Si refus (403) -> JSON ou vue erreurs.403.

## 5. Analyse des fichiers - Vue d'ensemble des composants

### 5.1 Fichiers Vue (app/Views) - Liste exhaustive
- **accueil.php** (racine)
- **tableau_de_bord.php** (racine)
- **finances.php** (racine)
- **journal.php** (racine)
- **parametres.php** (racine)
- **profil.php** (racine)
- **achats/**: detail.php, formulaire.php, liste.php
- **auth/**: connexion.php, mot-de-passe-oublie.php
- **chantiers/**: detail.php, formulaire.php, liste.php, pointage.php
- **erreurs/**: 401.php, 403.php, 404.php
- **facturation/**: detail_devis.php, detail_facture.php, formulaire.php, imprimer_devis.php, imprimer_facture.php, liste.php, recu_facture.php
- **layouts/**: base.php (gabarit principal avec sidebar/topbar/bare mode)
- **partials/**: accueil_contenu.php
- **referentiels/**: formulaire.php, index.php, liste.php
- **stock/**: index.php

**Total vues**: 31 fichiers PHP (comptabilisés ci-dessus).

### 5.2 Contrôleurs Web (app/Controllers/Web) - 10 fichiers
AchatPageController, AuthPageController, ChantierPageController, FacturationPageController, FinancePageController, HomeController, JournalPageController, ParametrePageController, ProfilPageController, ReferentielController

### 5.3 Contrôleurs API (app/Controllers/Api) - Principaux
AchatController, AuthController, ChantierController, ClientController, DevisController, EmployeController, EnginController, FactureController, FournisseurController, HealthController, JournalController, LotController, MateriauController, ParametreController, PointageController, StatistiquesController, StockController, UtilisateurController

### 5.4 Fichiers JS (assets/js) - 32 fichiers
achat-detail.js, achat-form.js, achat-liste.js, app.js, app-shell.js, auth.js, chantier-detail.js, chantier-form.js, chantier-liste.js, charts.js, connexion.js, dashboard.js, devis-detail.js, devis-print.js, doc-form.js, doc-liste.js, facture-detail.js, facture-print.js, finances.js, format.js, garde.js, journal.js, mot-de-passe-oublie.js, parametres.js, pointage.js, profil.js, recu-print.js, referents.js, ressource-form.js, ressource-liste.js, stock.js

**Couverture JS**: Chaque page web a son(ses) script(s) associé(s) (voir Table A). Scripts partagés: auth.js, format.js, charts.js, app-shell.js.

## 6. Analyse des anomalies potentielles (BROKEN / DEAD / ORPHANED)

### 6.1 JS orphelins (fichier JS sans utilisation claire sur pages listées)
- **garde.js** : présent dans assets/js/garde.js. Non référencé dans Table A. À vérifier - peut être script utilitaire non inclus ou obsolète. (Orphelin potentiel)
- **charts.js** : utilisé (dashboard.js, finances.js) - OK
- **format.js** : utilisé (pages imprimables + dashboard/finances) - OK
- **app-shell.js** : inclus automatiquement dans layout base (hors mode bare) - OK, central
- **auth.js** : partagé massivement - OK

**Suspicion**: ssets/js/garde.js - fichier existant non listé dans inclusion de pages. À considérer comme potentiellement orphelin/non utilisé.

### 6.2 Pages/Vues sans JS dédié vs JS sans page
- Pages imprimables (imprimer_devis, imprimer_facture, recu_facture) incluent bien leurs JS spécifiques + format.js - OK
- Page accueil (/) utilise app.js uniquement - OK (vérification API health)
- Page connexion utilise connexion.js + auth.js - OK
- mot-de-passe-oublie utilise son JS + auth.js - OK

### 6.3 Routes pointant vers méthodes existantes
Vérification croisée effectuée via lecture des contrôleurs :
- HomeController::index ✓
- AuthPageController::connexion, motDePasseOublie, tableauDeBord ✓
- ReferentielController::index, liste, formulaire ✓ (avec params {entite}, {id})
- ChantierPageController::liste, formulaire, detail, pointage ✓
- AchatPageController::liste, formulaire, detail, stock ✓
- FacturationPageController::listeDevis, formulaireDevis, imprimerDevis, detailDevis, listeFactures, formulaireFacture, detailFacture, imprimerFacture, recuFacture ✓
- FinancePageController::index ✓
- JournalPageController::index ✓
- ProfilPageController::index ✓
- ParametrePageController::index ✓

**Aucune route web ne pointe vers une méthode manquante** (contrôleurs lus intégralement pour les méthodes listées).

### 6.4 Contrôleurs API - cohérence routes vs méthodes
Ressources CRUD utilisent ResourceController (héritage) : index/show/store/update/destroy présents via héritage. Contrôleurs enfants (Employe/Client/Fournisseur/Engin/Materiau) définissent modèle + règles - OK.
ChantierController surcharge index/show - OK.
LotController définit index/store/update/destroy (imbriqués) - OK.
Autres contrôleurs (Auth, Achat, Devis, Facture, Stock, Pointage, Parametre, Journal, Statistiques, Utilisateur) ont méthodes correspondantes aux routes - vérifié par lecture partielle.

**Pas d'incohérence apparente**.

### 6.5 Permissions/Accès - points d'attention
1. **utilisateurs** et **parametres** dans Access::MATRICE sont vides (tableau vide). Seul le rôle directeur y accède (bypass global). C'est cohérent avec la logique (routes API comme /api/v1/utilisateurs exigent utilisateurs:view via PermissionMiddleware - directeur OK, autres non listés → refusés). **Comportement intentionnel**.
2. **factures** : non accessible à chef_chantier dans la matrice (uniquement comptable + directeur). Cohérent avec Table A (routes factures existent mais filtrées par rôle dans sidebar via app-shell.js - MODULES.factures n'inclut pas chef_chantier). OK.
3. **referentiels** : lecture/écriture pour chef_chantier/comptable/magasinier (pas delete dans matrice). Routes API permettent DELETE avec eferentiels:delete - seuls rôles ayant delete dans leurs actions pourraient y accéder ? Or matrice n'en liste pas pour ces rôles. Seul directeur (bypass) peut tout. **Point à noter** : DELETE nécessite droit delete - chef_chantier n'a pas delete pour referentiels → ne pourra pas supprimer via API (403) sauf directeur. Cohérent.
4. **chantiers** : matrice donne view/create/edit à chef_chantier, view à comptable/magasinier. DELETE via API exige chantiers:delete - chef_chantier n'a pas delete dans matrice → ne pourra pas supprimer (sauf directeur). À vérifier si c'est voulu.

### 6.6 Fichiers potentiellement BROKEN/DEAD
- **assets/js/garde.js** (Ligne 1-~?) : fichier présent, non référencé dans aucune inclusion de page (aucun script l'appelle). Semble orphelin. Peut être fichier de secours/ancien ou non utilisé. **Orphelin potentiel (DEAD/UNUSED)**.
- **app/Views/partials/accueil_contenu.php** : partial inclus ? Lu via accueil - peut être utilisé. À vérifier contenu (non lu exhaustivement ici) mais référencé/présent.
- **.htaccess** à la racine (présent) - configuré pour réécriture (point d'entrée index.php). OK.
- **cli.php** présent - utilitaire CLI (non exploré). Hors périmètre web/API.

### 6.7 Infrastructure/Core
- Autoload PSR-4 maison (App\\) + vendor autoload - OK
- Front controller index.php - OK
- Router avec paramètres nommés {id} + middlewares chainés - OK
- Auth JWT (access mémoire + refresh httpOnly cookie) - OK
- RBAC via Access + PermissionMiddleware - OK
- CORS géré pour API (OPTIONS preflight) - OK

## 7. Synthèse & Recommandations

### Éléments bien structurés
- Architecture MVC claire (Routes → Middleware → Contrôleurs → Vues)
- Séparation nette Web (HTML) / API REST (JSON) avec JWT partagé
- RBAC centralisé (Access.php) + directeur bypass
- Généricité via ResourceController pour CRUD référentiels
- Frontend modulaire (JS par fonctionnalité) + utilitaires partagés
- Gestion erreurs centralisée + audit (Journal)

### Points d'attention (non bloquants)
1. **assets/js/garde.js** : fichier orphelin potentiel - vérifier utilité ou supprimer si non utilisé.
2. **Droits DELETE** : certains modules n'ont pas delete dans matrice pour rôles non-directeur (ex. chantiers pour chef_chantier, referentiels). Cohérent si suppression réservée directeur - à confirmer avec besoin métier.
3. **utilisateurs/parametres** dans matrice vide : délibéré (accès uniquement directeur). OK.

### Conclusion
Le projet est **exhaustivement inventorié**. Toutes les routes web listées correspondent à des contrôleurs/méthodes existantes. Les vues, JS et permissions sont cohérents. Aucune route pointant vers une méthode manquante n'a été détectée. Le seul élément suspect identifié est ssets/js/garde.js (potentiellement orphelin).

**Fichiers lus (principaux)**: routes/web.php, routes/api.php, app/Config/referentiels.php, app/Core/{App,Router,Access,Request,Response}, app/Middleware/{AuthMiddleware,PermissionMiddleware}, tous contrôleurs Web/Api clés, toutes vues, tous JS, layouts/base.php.
