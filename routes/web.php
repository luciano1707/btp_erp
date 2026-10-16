<?php

/**
 * Routes web (pages HTML servies par le backend).
 * Ces pages consomment l'API interne via fetch cote navigateur.
 */

use App\Controllers\Web\AchatPageController;
use App\Controllers\Web\AuthPageController;
use App\Controllers\Web\ChantierPageController;
use App\Controllers\Web\FacturationPageController;
use App\Controllers\Web\FinancePageController;
use App\Controllers\Web\HomeController;
use App\Controllers\Web\JournalPageController;
use App\Controllers\Web\ParametrePageController;
use App\Controllers\Web\ProfilPageController;
use App\Controllers\Web\ReferentielController;
use App\Middleware\AuthMiddleware;
use App\Middleware\PermissionMiddleware;
use App\Core\Router;

return static function (Router $r): void {

    $page = static function (string $chemin, mixed $action, string $module, string $droit = 'view') use ($r): void {
        $r->get($chemin, $action, [AuthMiddleware::class, [PermissionMiddleware::class, $module, $droit]]);
    };

    // --- Accueil public ---
    $r->get('/', [HomeController::class, 'index']);

    // --- Authentification ---
    $r->get('/connexion',       [AuthPageController::class, 'connexion']);
    $r->get('/mot-de-passe-oublie', [AuthPageController::class, 'motDePasseOublie']);
    $page('/tableau-de-bord', [AuthPageController::class, 'tableauDeBord'], 'tableau_de_bord');

    // --- Referentiels (Phase 2) ---
    // La protection reelle est assuree cote API (JWT) ; ces pages sont des coquilles.
    $page('/referentiels',                         [ReferentielController::class, 'index'], 'referentiels');
    $page('/referentiels/{entite}',                [ReferentielController::class, 'liste'], 'referentiels');
    $r->get('/referentiels/{entite}/nouveau', [ReferentielController::class, 'formulaire'], [AuthMiddleware::class]);
    $r->get('/referentiels/{entite}/{id}/modifier', [ReferentielController::class, 'formulaire'], [AuthMiddleware::class]);

    // --- Chantiers (Phase 3) : ordre important (routes litterales avant {id}) ---
    $page('/chantiers',                 [ChantierPageController::class, 'liste'], 'chantiers');
    $page('/chantiers/nouveau',         [ChantierPageController::class, 'formulaire'], 'chantiers', 'create');
    $page('/chantiers/{id}/modifier',   [ChantierPageController::class, 'formulaire'], 'chantiers', 'edit');
    $page('/chantiers/{id}/pointage',   [ChantierPageController::class, 'pointage'], 'pointages');
    $page('/chantiers/{id}',            [ChantierPageController::class, 'detail'], 'chantiers');

    // --- Achats & stock (Phase 5) ---
    $page('/achats',          [AchatPageController::class, 'liste'], 'achats');
    $page('/achats/nouveau',  [AchatPageController::class, 'formulaire'], 'achats', 'create');
    $page('/achats/{id}',     [AchatPageController::class, 'detail'], 'achats');
    $page('/stock',           [AchatPageController::class, 'stock'], 'stock');

    // --- Devis & factures (Phase 6) ---
    $page('/devis',            [FacturationPageController::class, 'listeDevis'], 'devis');
    $page('/devis/nouveau',    [FacturationPageController::class, 'formulaireDevis'], 'devis', 'create');
    $page('/devis/{id}/imprimer', [FacturationPageController::class, 'imprimerDevis'], 'devis');
    $page('/devis/{id}',        [FacturationPageController::class, 'detailDevis'], 'devis');
    $page('/factures',         [FacturationPageController::class, 'listeFactures'], 'factures');
    $page('/factures/nouveau', [FacturationPageController::class, 'formulaireFacture'], 'factures', 'create');
    $page('/factures/{id}',    [FacturationPageController::class, 'detailFacture'], 'factures');

    // --- Suivi financier (Phase 7) ---
    $page('/finances', [FinancePageController::class, 'index'], 'finances');

    // --- Journal d'audit (Phase 8) ---
    $page('/journal', [JournalPageController::class, 'index'], 'journal');

    // --- Parametres ---
    $page('/profil',      [ProfilPageController::class, 'index'], 'profil');
    $page('/parametres', [ParametrePageController::class, 'index'], 'parametres');
    $page('/factures/{id}/imprimer', [FacturationPageController::class, 'imprimerFacture'], 'factures');
    $page('/factures/{id}/recu',     [FacturationPageController::class, 'recuFacture'], 'factures');
};
