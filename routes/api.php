<?php

/**
 * Routes de l'API REST (prefixe /api/v1).
 * Cette API est la source unique de verite : elle sera consommee a l'identique
 * par le front web (fetch/AJAX) et par l'application mobile React Native.
 */

use App\Controllers\Api\AchatController;
use App\Controllers\Api\AuthController;
use App\Controllers\Api\ChantierController;
use App\Controllers\Api\ClientController;
use App\Controllers\Api\DevisController;
use App\Controllers\Api\EmployeController;
use App\Controllers\Api\FactureController;
use App\Controllers\Api\EnginController;
use App\Controllers\Api\FournisseurController;
use App\Controllers\Api\HealthController;
use App\Controllers\Api\JournalController;
use App\Controllers\Api\LotController;
use App\Controllers\Api\MateriauController;
use App\Controllers\Api\ParametreController;
use App\Controllers\Api\PointageController;
use App\Controllers\Api\StatistiquesController;
use App\Controllers\Api\StockController;
use App\Controllers\Api\UtilisateurController;
use App\Core\Router;
use App\Middleware\AuthMiddleware;
use App\Middleware\PermissionMiddleware;

return static function (Router $r): void {

    // --- Controle de sante (public) ---
    $r->get('/api/v1/health', [HealthController::class, 'index']);

    // --- Authentification ---
    $r->post('/api/v1/auth/login',   [AuthController::class, 'login']);
    $r->post('/api/v1/auth/mot-de-passe-oublie', [AuthController::class, 'motDePasseOublie']);
    $r->post('/api/v1/auth/reinitialiser-mot-de-passe', [AuthController::class, 'reinitialiserMotDePasse']);
    $r->post('/api/v1/auth/refresh', [AuthController::class, 'refresh']);
    $r->post('/api/v1/auth/logout',  [AuthController::class, 'logout']);
    $r->get('/api/v1/auth/me',            [AuthController::class, 'moi'],               [AuthMiddleware::class]);
    $r->put('/api/v1/auth/me',            [AuthController::class, 'modifierProfil'],    [AuthMiddleware::class]);
    $r->post('/api/v1/auth/mot-de-passe', [AuthController::class, 'changerMotDePasse'], [AuthMiddleware::class]);

    // --- Referentiels (Phase 2) ---
    // Lecture : tout utilisateur connecte. Ecriture : roles precises (le directeur a tout).
    $ressource = static function (string $chemin, string $ctrl, string $module) use ($r): void {
        $lecture  = [AuthMiddleware::class, [PermissionMiddleware::class, $module, 'view']];
        $ecriture = static function (string $droit) use ($module): array {
            return [AuthMiddleware::class, [PermissionMiddleware::class, $module, $droit]];
        };

        $r->get("/api/v1/$chemin",        [$ctrl, 'index'],   $lecture);
        $r->get("/api/v1/$chemin/{id}",   [$ctrl, 'show'],    $lecture);
        $r->post("/api/v1/$chemin",       [$ctrl, 'store'],   $ecriture('create'));
        $r->put("/api/v1/$chemin/{id}",   [$ctrl, 'update'],  $ecriture('edit'));
        $r->delete("/api/v1/$chemin/{id}", [$ctrl, 'destroy'], $ecriture('delete'));
    };

    $ressource('employes',     EmployeController::class,     'employes');
    $ressource('clients',      ClientController::class,      'clients');
    $ressource('fournisseurs', FournisseurController::class, 'fournisseurs');
    $ressource('engins',       EnginController::class,       'engins');
    $ressource('materiaux',    MateriauController::class,    'materiaux');

    // --- Chantiers & lots (Phase 3) ---
    $lecture = [AuthMiddleware::class, [PermissionMiddleware::class, 'chantiers', 'view']];
    $lectureLots = [AuthMiddleware::class, [PermissionMiddleware::class, 'lots', 'view']];
    $ecritureLots = static function (string $droit): array {
        return [AuthMiddleware::class, [PermissionMiddleware::class, 'lots', $droit]];
    };
    $lecturePointages = [AuthMiddleware::class, [PermissionMiddleware::class, 'pointages', 'view']];
    $ecriturePointages = static function (string $droit): array {
        return [AuthMiddleware::class, [PermissionMiddleware::class, 'pointages', $droit]];
    };
    $ecritureChantier = static function (string $droit): array {
        return [AuthMiddleware::class, [PermissionMiddleware::class, 'chantiers', $droit]];
    };

    $r->get('/api/v1/chantiers',       [ChantierController::class, 'index'],   $lecture);
    $r->get('/api/v1/chantiers/{id}',  [ChantierController::class, 'show'],    $lecture);
    $r->post('/api/v1/chantiers',       [ChantierController::class, 'store'],   $ecritureChantier('create'));
    $r->put('/api/v1/chantiers/{id}',  [ChantierController::class, 'update'],  $ecritureChantier('edit'));
    $r->delete('/api/v1/chantiers/{id}', [ChantierController::class, 'destroy'], $ecritureChantier('delete'));

    $r->get('/api/v1/chantiers/{id}/lots',  [LotController::class, 'index'], $lectureLots);
    $r->post('/api/v1/chantiers/{id}/lots', [LotController::class, 'store'], $ecritureLots('create'));
    $r->put('/api/v1/lots/{id}',    [LotController::class, 'update'],  $ecritureLots('edit'));
    $r->delete('/api/v1/lots/{id}', [LotController::class, 'destroy'], $ecritureLots('delete'));

    // Liste des utilisateurs (pour selecteurs) : tout utilisateur connecte
    $r->get('/api/v1/utilisateurs', [UtilisateurController::class, 'index'], [AuthMiddleware::class, [PermissionMiddleware::class, 'utilisateurs', 'view']]);

    // --- Pointage & main d'oeuvre (Phase 4) ---
    $r->get('/api/v1/chantiers/{id}/pointages',  [PointageController::class, 'parChantier'],       $lecturePointages);
    $r->post('/api/v1/chantiers/{id}/pointages', [PointageController::class, 'enregistrerFeuille'], $ecriturePointages('edit'));
    $r->delete('/api/v1/pointages/{id}',         [PointageController::class, 'destroy'],            $ecriturePointages('delete'));

    // --- Achats & stock (Phase 5) ---
    $lectureAchats = [AuthMiddleware::class, [PermissionMiddleware::class, 'achats', 'view']];
    $lectureStock = [AuthMiddleware::class, [PermissionMiddleware::class, 'stock', 'view']];
    $ecritureAchat = static function (string $droit): array {
        return [AuthMiddleware::class, [PermissionMiddleware::class, 'achats', $droit]];
    };
    $ecritureStock = static function (string $droit): array {
        return [AuthMiddleware::class, [PermissionMiddleware::class, 'stock', $droit]];
    };

    $r->get('/api/v1/achats',             [AchatController::class, 'index'], $lectureAchats);
    $r->get('/api/v1/achats/{id}',        [AchatController::class, 'show'],  $lectureAchats);
    $r->post('/api/v1/achats',            [AchatController::class, 'store'], $ecritureAchat('create'));
    $r->post('/api/v1/achats/{id}/reception', [AchatController::class, 'reception'], $ecritureAchat('validate'));
    $r->post('/api/v1/achats/{id}/annuler',   [AchatController::class, 'annuler'],   $ecritureAchat('delete'));
    $r->delete('/api/v1/achats/{id}',     [AchatController::class, 'destroy'], $ecritureAchat('delete'));

    $r->get('/api/v1/stock',                    [StockController::class, 'index'],      $lectureStock);
    $r->get('/api/v1/materiaux/{id}/mouvements', [StockController::class, 'historique'], $lectureStock);
    $r->post('/api/v1/mouvements',              [StockController::class, 'mouvement'],  $ecritureStock('create'));

    // --- Devis & facturation (Phase 6) ---
    $lectureDevis = [AuthMiddleware::class, [PermissionMiddleware::class, 'devis', 'view']];
    $lectureFactures = [AuthMiddleware::class, [PermissionMiddleware::class, 'factures', 'view']];
    $ecritureDevis = static function (string $droit): array {
        return [AuthMiddleware::class, [PermissionMiddleware::class, 'devis', $droit]];
    };
    $ecritureFactures = static function (string $droit): array {
        return [AuthMiddleware::class, [PermissionMiddleware::class, 'factures', $droit]];
    };

    $r->get('/api/v1/devis',            [DevisController::class, 'index'], $lectureDevis);
    $r->get('/api/v1/devis/{id}',       [DevisController::class, 'show'],  $lectureDevis);
    $r->post('/api/v1/devis',           [DevisController::class, 'store'], $ecritureDevis('create'));
    $r->put('/api/v1/devis/{id}/statut', [DevisController::class, 'changerStatut'], $ecritureDevis('validate'));
    $r->post('/api/v1/devis/{id}/facturer', [DevisController::class, 'facturer'],   $ecritureDevis('validate'));
    $r->delete('/api/v1/devis/{id}',    [DevisController::class, 'destroy'], $ecritureDevis('delete'));

    $r->get('/api/v1/factures',         [FactureController::class, 'index'], $lectureFactures);
    $r->get('/api/v1/factures/{id}',    [FactureController::class, 'show'],  $lectureFactures);
    $r->post('/api/v1/factures',        [FactureController::class, 'store'], $ecritureFactures('create'));
    $r->post('/api/v1/factures/{id}/emettre',   [FactureController::class, 'emettre'],         $ecritureFactures('validate'));
    $r->post('/api/v1/factures/{id}/paiements', [FactureController::class, 'ajouterPaiement'], $ecritureFactures('edit'));
    $r->post('/api/v1/factures/{id}/annuler',   [FactureController::class, 'annuler'],         $ecritureFactures('delete'));
    $r->delete('/api/v1/factures/{id}', [FactureController::class, 'destroy'], $ecritureFactures('delete'));

    // --- Parametres entreprise : lecture pour tous, ecriture directeur ---
    $r->get('/api/v1/parametres',       [ParametreController::class, 'index'], [AuthMiddleware::class, [PermissionMiddleware::class, 'parametres', 'view']]);
    $r->put('/api/v1/parametres',       [ParametreController::class, 'update'], [AuthMiddleware::class, [PermissionMiddleware::class, 'parametres', 'edit']]);
    $r->post('/api/v1/parametres/logo', [ParametreController::class, 'televerserLogo'], [AuthMiddleware::class, [PermissionMiddleware::class, 'parametres', 'edit']]);

    // --- Journal d'audit (Phase 8) : directeur uniquement ---
    $journal = [AuthMiddleware::class, [PermissionMiddleware::class, 'journal', 'view']];
    $r->get('/api/v1/journal', [JournalController::class, 'index'], $journal);
    $r->get('/api/v1/journal/{id}', [JournalController::class, 'show'], $journal);

    // --- Statistiques & suivi financier (Phase 7) : lecture pour tout utilisateur connecte ---
    $r->get('/api/v1/stats/tableau-de-bord', [StatistiquesController::class, 'tableauDeBord'],       [AuthMiddleware::class, [PermissionMiddleware::class, 'tableau_de_bord', 'view']]);
    $r->get('/api/v1/stats/chantiers', [StatistiquesController::class, 'rentabiliteChantiers'], [AuthMiddleware::class, [PermissionMiddleware::class, 'tableau_de_bord', 'view']]);
    $r->get('/api/v1/stats/mensuel',         [StatistiquesController::class, 'mensuel'],             [AuthMiddleware::class, [PermissionMiddleware::class, 'finances', 'view']]);
    $r->get('/api/v1/stats/tresorerie',      [StatistiquesController::class, 'tresorerie'],         [AuthMiddleware::class, [PermissionMiddleware::class, 'finances', 'view']]);
};
