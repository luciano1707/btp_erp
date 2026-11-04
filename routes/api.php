<?php

/**
 * Routes de l'API REST (prefixe /api/v1).
 * Cette API est la source unique de verite : elle sera consommee a l'identique
 * par le front web (fetch/AJAX) et par l'application mobile Flutter.
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
use App\Controllers\Api\DemandeMaterielController;
use App\Controllers\Api\RapportJournalierController;
use App\Controllers\Api\DepenseController;
use App\Controllers\Api\BudgetController;
use App\Controllers\Api\RfiController;
use App\Controllers\Api\QualiteController;
use App\Controllers\Api\SecuriteController;
use App\Controllers\Api\ExportController;
use App\Controllers\Api\IncidentController;
use App\Controllers\Api\NotificationController;
use App\Controllers\Api\ValidationController;
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
    $r->post('/api/v1/devis/{id}/soumettre', [DevisController::class, 'soumettre'], $ecritureDevis('create'));
    $r->put('/api/v1/devis/{id}/statut', [DevisController::class, 'changerStatut'], $ecritureDevis('edit'));
    $r->post('/api/v1/devis/{id}/facturer', [DevisController::class, 'facturer'],   $ecritureDevis('create'));
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

    // --- Demandes de materiel ---
    $lectureDemande = [AuthMiddleware::class, [PermissionMiddleware::class, 'demandes_materiel', 'view']];
    $createDemande  = [AuthMiddleware::class, [PermissionMiddleware::class, 'demandes_materiel', 'create']];
    $traiterDemande = [AuthMiddleware::class, [PermissionMiddleware::class, 'demandes_materiel', 'validate']];

    $r->get('/api/v1/demandes-materiel',                [DemandeMaterielController::class, 'index'],      $lectureDemande);
    $r->get('/api/v1/demandes-materiel/{id}',           [DemandeMaterielController::class, 'show'],       $lectureDemande);
    $r->post('/api/v1/demandes-materiel',               [DemandeMaterielController::class, 'store'],      $createDemande);
    $r->post('/api/v1/demandes-materiel/{id}/approuver', [DemandeMaterielController::class, 'approuver'], $traiterDemande);
    $r->post('/api/v1/demandes-materiel/{id}/refuser',   [DemandeMaterielController::class, 'refuser'],   $traiterDemande);
    $r->post('/api/v1/demandes-materiel/{id}/traiter',   [DemandeMaterielController::class, 'traiter'],   $traiterDemande);

    // --- Rapports journaliers ---
    $lectureRapport = [AuthMiddleware::class, [PermissionMiddleware::class, 'rapports_journaliers', 'view']];
    $createRapport  = [AuthMiddleware::class, [PermissionMiddleware::class, 'rapports_journaliers', 'create']];
    $editRapport    = [AuthMiddleware::class, [PermissionMiddleware::class, 'rapports_journaliers', 'edit']];

    $r->get('/api/v1/rapports-journaliers',      [RapportJournalierController::class, 'index'],   $lectureRapport);
    $r->get('/api/v1/rapports-journaliers/{id}', [RapportJournalierController::class, 'show'],    $lectureRapport);
    $r->post('/api/v1/rapports-journaliers',     [RapportJournalierController::class, 'store'],   $createRapport);
    $r->put('/api/v1/rapports-journaliers/{id}', [RapportJournalierController::class, 'update'],  $editRapport);
    $r->post('/api/v1/rapports-journaliers/{id}/soumettre', [RapportJournalierController::class, 'soumettre'], $editRapport);

    // --- Depenses ---
    $lectureDepense = [AuthMiddleware::class, [PermissionMiddleware::class, 'depenses', 'view']];
    $createDepense  = [AuthMiddleware::class, [PermissionMiddleware::class, 'depenses', 'create']];
    $validerDepense = [AuthMiddleware::class, [PermissionMiddleware::class, 'depenses', 'validate']];

    $r->get('/api/v1/depenses',                [DepenseController::class, 'index'],    $lectureDepense);
    $r->get('/api/v1/depenses/{id}',           [DepenseController::class, 'show'],     $lectureDepense);
    $r->post('/api/v1/depenses',               [DepenseController::class, 'store'],    $createDepense);
    $r->post('/api/v1/depenses/{id}/soumettre', [DepenseController::class, 'soumettre'], $createDepense);
    $r->post('/api/v1/depenses/{id}/valider',  [DepenseController::class, 'traiterValidation'], $validerDepense);
    $r->post('/api/v1/depenses/{id}/rejeter',  [DepenseController::class, 'rejeter'],   $validerDepense);

    // --- Budgets ---
    $lectureBudget = [AuthMiddleware::class, [PermissionMiddleware::class, 'budgets', 'view']];
    $editBudget    = [AuthMiddleware::class, [PermissionMiddleware::class, 'budgets', 'edit']];

    $r->get('/api/v1/budgets',           [BudgetController::class, 'index'],  $lectureBudget);
    $r->get('/api/v1/budgets/{id}',      [BudgetController::class, 'show'],   $lectureBudget);
    $r->post('/api/v1/budgets',          [BudgetController::class, 'store'],  $editBudget);
    $r->put('/api/v1/budgets/{id}',      [BudgetController::class, 'update'], $editBudget);

    // --- RFI / Qualite / Securite / Incidents ---
    $lectureRfi = [AuthMiddleware::class, [PermissionMiddleware::class, 'rfi', 'view']];
    $createRfi  = [AuthMiddleware::class, [PermissionMiddleware::class, 'rfi', 'create']];
    $editRfi    = [AuthMiddleware::class, [PermissionMiddleware::class, 'rfi', 'edit']];
    $r->get('/api/v1/rfi',      [RfiController::class, 'index'],  $lectureRfi);
    $r->get('/api/v1/rfi/{id}', [RfiController::class, 'show'],   $lectureRfi);
    $r->post('/api/v1/rfi',     [RfiController::class, 'store'],  $createRfi);
    $r->post('/api/v1/rfi/{id}/repondre', [RfiController::class, 'repondre'], $editRfi);

    $lectureQualite = [AuthMiddleware::class, [PermissionMiddleware::class, 'qualite', 'view']];
    $createQualite  = [AuthMiddleware::class, [PermissionMiddleware::class, 'qualite', 'create']];
    $editQualite    = [AuthMiddleware::class, [PermissionMiddleware::class, 'qualite', 'edit']];
    $r->get('/api/v1/qualite',      [QualiteController::class, 'index'],  $lectureQualite);
    $r->get('/api/v1/qualite/{id}', [QualiteController::class, 'show'],   $lectureQualite);
    $r->post('/api/v1/qualite',     [QualiteController::class, 'store'],  $createQualite);
    $r->put('/api/v1/qualite/{id}', [QualiteController::class, 'update'], $editQualite);

    $lectureSecurite = [AuthMiddleware::class, [PermissionMiddleware::class, 'securite', 'view']];
    $createSecurite  = [AuthMiddleware::class, [PermissionMiddleware::class, 'securite', 'create']];
    $editSecurite    = [AuthMiddleware::class, [PermissionMiddleware::class, 'securite', 'edit']];
    $r->get('/api/v1/securite',      [SecuriteController::class, 'index'],  $lectureSecurite);
    $r->get('/api/v1/securite/{id}', [SecuriteController::class, 'show'],   $lectureSecurite);
    $r->post('/api/v1/securite',     [SecuriteController::class, 'store'],  $createSecurite);
    $r->put('/api/v1/securite/{id}', [SecuriteController::class, 'update'], $editSecurite);

    $lectureIncident = [AuthMiddleware::class, [PermissionMiddleware::class, 'incidents', 'view']];
    $createIncident  = [AuthMiddleware::class, [PermissionMiddleware::class, 'incidents', 'create']];
    $editIncident    = [AuthMiddleware::class, [PermissionMiddleware::class, 'incidents', 'edit']];
    $r->get('/api/v1/incidents',      [IncidentController::class, 'index'],  $lectureIncident);
    $r->get('/api/v1/incidents/{id}', [IncidentController::class, 'show'],   $lectureIncident);
    $r->post('/api/v1/incidents',     [IncidentController::class, 'store'],  $createIncident);
    $r->put('/api/v1/incidents/{id}', [IncidentController::class, 'update'], $editIncident);

    // --- Notifications ---
    $lectureNotif = [AuthMiddleware::class, [PermissionMiddleware::class, 'notifications', 'view']];
    $r->get('/api/v1/notifications', [NotificationController::class, 'index'], $lectureNotif);
    $r->post('/api/v1/notifications/tout-lire', [NotificationController::class, 'toutLire'], $lectureNotif);
    $r->post('/api/v1/notifications/{id}/lue', [NotificationController::class, 'marquerLue'], $lectureNotif);

    // --- Validations centralisees ---
    $lectureValidation = [AuthMiddleware::class, [PermissionMiddleware::class, 'validation', 'view']];
    $validerValidation = [AuthMiddleware::class, [PermissionMiddleware::class, 'validation', 'validate']];
    $r->get('/api/v1/validations/indicateurs', [ValidationController::class, 'indicateurs'], $lectureValidation);
    $r->get('/api/v1/validations/en-attente', [ValidationController::class, 'enAttente'], $lectureValidation);
    $r->get('/api/v1/validations', [ValidationController::class, 'index'], $lectureValidation);
    $r->post('/api/v1/validations', [ValidationController::class, 'store'], $lectureValidation);
    $r->post('/api/v1/validations/soumettre', [ValidationController::class, 'soumettreOperation'], $lectureValidation);
    $r->get('/api/v1/validations/{id}', [ValidationController::class, 'show'], $lectureValidation);
    $r->post('/api/v1/validations/{id}/soumettre', [ValidationController::class, 'soumettre'], $lectureValidation);
    $r->post('/api/v1/validations/{id}/valider', [ValidationController::class, 'approuver'], $validerValidation);
    $r->post('/api/v1/validations/{id}/refuser', [ValidationController::class, 'refuser'], $validerValidation);

    // --- Exports (permissions verifiees dans le controleur selon le module) ---
    $r->post('/api/v1/export/xlsx', [ExportController::class, 'exportXLSX'], [AuthMiddleware::class]);
    $r->post('/api/v1/export/csv', [ExportController::class, 'exportCSV'], [AuthMiddleware::class]);
    $r->post('/api/v1/export/pdf', [ExportController::class, 'exportPDF'], [AuthMiddleware::class]);
    $r->post('/api/v1/export/devis-pdf', [ExportController::class, 'exportDevisPDF'], [AuthMiddleware::class]);
    $r->post('/api/v1/export/rapport-financier-pdf', [ExportController::class, 'exportRapportFinancierPDF'], [AuthMiddleware::class]);
    $r->post('/api/v1/export/rapport-financier-xlsx', [ExportController::class, 'exportRapportFinancierXLSX'], [AuthMiddleware::class]);

    // --- Statistiques & suivi financier (Phase 7) : lecture pour tout utilisateur connecte ---
    $r->get('/api/v1/stats/tableau-de-bord', [StatistiquesController::class, 'tableauDeBord'],       [AuthMiddleware::class, [PermissionMiddleware::class, 'tableau_de_bord', 'view']]);
    $r->get('/api/v1/stats/chantiers', [StatistiquesController::class, 'rentabiliteChantiers'], [AuthMiddleware::class, [PermissionMiddleware::class, 'tableau_de_bord', 'view']]);
    $r->get('/api/v1/stats/mensuel',         [StatistiquesController::class, 'mensuel'],             [AuthMiddleware::class, [PermissionMiddleware::class, 'finances', 'view']]);
    $r->get('/api/v1/stats/tresorerie',      [StatistiquesController::class, 'tresorerie'],         [AuthMiddleware::class, [PermissionMiddleware::class, 'finances', 'view']]);
};
