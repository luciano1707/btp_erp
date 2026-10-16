<?php

namespace App\Controllers\Api;

use App\Core\Audit;
use App\Core\Controller;
use App\Core\Request;
use App\Core\Response;
use App\Models\Facture;
use App\Models\Paiement;

/** API des factures et de leurs paiements (Phase 6). */
final class FactureController extends Controller
{
    private const CHAMPS = ['reference', 'client_id', 'chantier_id', 'date_facture', 'echeance', 'notes'];

    /** GET /api/v1/factures */
    public function index(Request $requete): void
    {
        $limite = max(1, min((int) $requete->query('limite', 50), 200));
        $page   = max(1, (int) $requete->query('page', 1));
        $res    = (new Facture())->liste((string) $requete->query('recherche', ''), $limite, ($page - 1) * $limite);
        Response::succes(['elements' => $res['lignes'], 'total' => $res['total'], 'page' => $page, 'limite' => $limite], 'Liste des factures');
    }

    /** GET /api/v1/factures/{id} */
    public function show(Request $requete): void
    {
        $facture = (new Facture())->trouverAvecLignes((int) $requete->params['id']);
        if ($facture === null) {
            Response::erreur('Facture introuvable.', 404);
        }
        Response::succes($facture);
    }

    /** POST /api/v1/factures (facture directe, sans devis) */
    public function store(Request $requete): void
    {
        $this->valider($requete->tout(), ['date_facture' => 'requis']);
        $lignes = $requete->input('lignes', []);
        if (!is_array($lignes) || $lignes === []) {
            Response::erreur('Au moins une ligne est requise.', 422);
        }

        $entete = $this->filtrer($requete->tout());
        $entete['statut'] = 'brouillon';
        $entete['cree_par'] = $this->uid($requete);
        $tva = (float) ($requete->input('tva_taux', 20));

        try {
            $id = (new Facture())->creerAvecLignes($entete, $lignes, $tva);
        } catch (\PDOException $e) {
            if ($e->getCode() === '23000') {
                Response::erreur('Reference de facture deja utilisee.', 422);
            }
            throw $e;
        }

        Audit::enregistrer('facture.creation', 'facture', $id, [], $this->uid($requete));
        Response::succes((new Facture())->trouverAvecLignes($id), 'Facture enregistree.', 201);
    }

    /** POST /api/v1/factures/{id}/emettre */
    public function emettre(Request $requete): void
    {
        $id = (int) $requete->params['id'];
        $modele = new Facture();
        $facture = $modele->trouver($id);
        if ($facture === null) {
            Response::erreur('Facture introuvable.', 404);
        }
        if ($facture['statut'] !== 'brouillon') {
            Response::erreur('Seule une facture en brouillon peut etre emise.', 409);
        }
        $modele->modifier($id, ['statut' => 'emise']);
        Audit::enregistrer('facture.emission', 'facture', $id, [], $this->uid($requete));
        Response::succes(null, 'Facture emise.');
    }

    /** POST /api/v1/factures/{id}/paiements */
    public function ajouterPaiement(Request $requete): void
    {
        $id = (int) $requete->params['id'];
        $modele = new Facture();
        $facture = $modele->trouver($id);
        if ($facture === null) {
            Response::erreur('Facture introuvable.', 404);
        }
        if ($facture['statut'] === 'annulee') {
            Response::erreur('Impossible d\'encaisser sur une facture annulee.', 409);
        }
        if ($facture['statut'] === 'brouillon') {
            Response::erreur('Emettez la facture avant d\'enregistrer un paiement.', 409);
        }

        $donnees = $this->valider($requete->tout(), [
            'montant' => 'requis|entier|min:1',
            'mode'    => 'dans:especes,cheque,virement,mobile_money,autre',
        ]);

        (new Paiement())->creer([
            'facture_id'         => $id,
            'date_paiement'      => $requete->input('date_paiement') ?: date('Y-m-d'),
            'montant'            => (int) $donnees['montant'],
            'mode'               => $requete->input('mode', 'especes'),
            'reference_paiement' => $requete->input('reference_paiement') ?: null,
            'cree_par'           => $this->uid($requete),
        ]);

        $modele->recalculerPaiements($id);
        Audit::enregistrer('facture.paiement', 'facture', $id, ['montant' => $donnees['montant']], $this->uid($requete));

        Response::succes((new Facture())->trouverAvecLignes($id), 'Paiement enregistre.', 201);
    }

    /** POST /api/v1/factures/{id}/annuler */
    public function annuler(Request $requete): void
    {
        $id = (int) $requete->params['id'];
        $modele = new Facture();
        $facture = $modele->trouver($id);
        if ($facture === null) {
            Response::erreur('Facture introuvable.', 404);
        }
        if ((int) $facture['montant_paye'] > 0) {
            Response::erreur('Une facture avec des paiements ne peut pas etre annulee.', 409);
        }
        $modele->modifier($id, ['statut' => 'annulee']);
        Audit::enregistrer('facture.annulation', 'facture', $id, [], $this->uid($requete));
        Response::succes(null, 'Facture annulee.');
    }

    /** DELETE /api/v1/factures/{id} */
    public function destroy(Request $requete): void
    {
        $id = (int) $requete->params['id'];
        $modele = new Facture();
        if ($modele->trouver($id) === null) {
            Response::erreur('Facture introuvable.', 404);
        }
        $modele->supprimer($id);
        Audit::enregistrer('facture.suppression', 'facture', $id, [], $this->uid($requete));
        Response::succes(null, 'Facture supprimee.');
    }

    private function filtrer(array $donnees): array
    {
        $out = array_intersect_key($donnees, array_flip(self::CHAMPS));
        foreach ($out as $k => $v) {
            if ($v === '') {
                $out[$k] = null;
            }
        }
        return $out;
    }

    private function uid(Request $requete): ?int
    {
        return isset($requete->auth['sub']) ? (int) $requete->auth['sub'] : null;
    }
}
