<?php

namespace App\Controllers\Web;

use App\Core\Controller;
use App\Core\Access;
use App\Core\Request;
use App\Core\Response;
use App\Core\ValidationService;
use App\Models\Devis;

/** Pages web des devis et factures (Phase 6). */
final class FacturationPageController extends Controller
{
    public function listeDevis(Request $r): void
    {
        $role = $r->auth['role'] ?? null;
        Response::vue('facturation.liste', [
            'titre'    => 'Devis',
            'type'     => 'devis',
            'endpoint' => 'api/v1/devis',
            'nouveau'  => '/devis/nouveau',
            'baseWeb'  => '/devis',
            'peutCreer' => Access::autorise($role, 'devis', 'create'),
            'statuts'  => ['brouillon' => 'Brouillon', 'envoye' => 'Envoye', 'accepte' => 'Accepte', 'refuse' => 'Refuse'],
        ]);
    }

    public function listeFactures(Request $r): void
    {
        $role = $r->auth['role'] ?? null;
        Response::vue('facturation.liste', [
            'titre'    => 'Factures',
            'type'     => 'facture',
            'endpoint' => 'api/v1/factures',
            'nouveau'  => '/factures/nouveau',
            'baseWeb'  => '/factures',
            'peutCreer' => Access::autorise($role, 'factures', 'create'),
            'statuts'  => ['brouillon' => 'Brouillon', 'emise' => 'Emise', 'payee_partiel' => 'Paye partiel', 'payee' => 'Payee', 'annulee' => 'Annulee'],
        ]);
    }

    public function formulaireDevis(Request $r): void
    {
        Response::vue('facturation.formulaire', [
            'titre' => 'Nouveau devis', 'type' => 'devis',
            'endpoint' => 'api/v1/devis', 'baseWeb' => '/devis', 'champDate' => 'date_devis', 'champEcheance' => 'validite', 'libelleEcheance' => 'Validite',
        ]);
    }

    public function formulaireFacture(Request $r): void
    {
        Response::vue('facturation.formulaire', [
            'titre' => 'Nouvelle facture', 'type' => 'facture',
            'endpoint' => 'api/v1/factures', 'baseWeb' => '/factures', 'champDate' => 'date_facture', 'champEcheance' => 'echeance', 'libelleEcheance' => 'Echeance',
        ]);
    }

    public function detailDevis(Request $r): void
    {
        $role = $r->auth['role'] ?? null;
        Response::vue('facturation.detail_devis', [
            'titre'         => 'Detail devis',
            'id'            => (int) $r->params['id'],
            'peutSoumettre' => Access::autorise($role, 'devis', 'edit'),
            'peutValider'   => $role === 'directeur',
            'peutFacturer'  => Access::autorise($role, 'devis', 'create'),
        ]);
    }

    /** GET /devis/{id}/imprimer : version imprimable, reservee aux devis valides. */
    public function imprimerDevis(Request $r): void
    {
        $id = (int) $r->params['id'];
        $devis = (new Devis())->trouver($id);
        if ($devis === null) {
            Response::vue('erreurs.404', [], 404);
        }
        $valide = ($devis['statut'] ?? '') === 'accepte'
            || (new ValidationService())->estValidee('devis', $id);
        if (!$valide) {
            Response::vue('erreurs.403', [], 403);
        }
        Response::vue('facturation.imprimer_devis', ['titre' => 'Devis', 'id' => $id]);
    }

    public function detailFacture(Request $r): void
    {
        $role = $r->auth['role'] ?? null;
        Response::vue('facturation.detail_facture', [
            'titre'       => 'Detail facture',
            'id'          => (int) $r->params['id'],
            'peutValider' => Access::autorise($role, 'factures', 'validate'),
            'peutPayer'   => Access::autorise($role, 'factures', 'edit'),
            'peutAnnuler' => Access::autorise($role, 'factures', 'delete'),
        ]);
    }

    /** GET /factures/{id}/imprimer : version imprimable (impression / PDF via navigateur). */
    public function imprimerFacture(Request $r): void
    {
        Response::vue('facturation.imprimer_facture', ['titre' => 'Facture', 'id' => (int) $r->params['id']]);
    }

    /** GET /factures/{id}/recu : recu de paiement imprimable. */
    public function recuFacture(Request $r): void
    {
        Response::vue('facturation.recu_facture', ['titre' => 'Recu de paiement', 'id' => (int) $r->params['id']]);
    }
}
