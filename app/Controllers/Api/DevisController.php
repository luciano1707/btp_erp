<?php

namespace App\Controllers\Api;

use App\Core\Audit;
use App\Core\Controller;
use App\Core\Request;
use App\Core\Response;
use App\Models\Devis;
use App\Models\Facture;

/** API des devis (Phase 6). */
final class DevisController extends Controller
{
    private const CHAMPS = ['reference', 'client_id', 'chantier_id', 'date_devis', 'validite', 'notes'];

    /** GET /api/v1/devis */
    public function index(Request $requete): void
    {
        $limite = max(1, min((int) $requete->query('limite', 50), 200));
        $page   = max(1, (int) $requete->query('page', 1));
        $res    = (new Devis())->liste((string) $requete->query('recherche', ''), $limite, ($page - 1) * $limite);
        Response::succes(['elements' => $res['lignes'], 'total' => $res['total'], 'page' => $page, 'limite' => $limite], 'Liste des devis');
    }

    /** GET /api/v1/devis/{id} */
    public function show(Request $requete): void
    {
        $devis = (new Devis())->trouverAvecLignes((int) $requete->params['id']);
        if ($devis === null) {
            Response::erreur('Devis introuvable.', 404);
        }
        Response::succes($devis);
    }

    /** POST /api/v1/devis */
    public function store(Request $requete): void
    {
        $this->valider($requete->tout(), ['date_devis' => 'requis']);
        $lignes = $requete->input('lignes', []);
        if (!is_array($lignes) || $lignes === []) {
            Response::erreur('Au moins une ligne est requise.', 422);
        }

        $entete = $this->filtrer($requete->tout());
        $entete['statut'] = 'brouillon';
        $entete['cree_par'] = $this->uid($requete);
        $tva = (float) ($requete->input('tva_taux', 20));

        try {
            $id = (new Devis())->creerAvecLignes($entete, $lignes, $tva);
        } catch (\PDOException $e) {
            if ($e->getCode() === '23000') {
                Response::erreur('Reference de devis deja utilisee.', 422);
            }
            throw $e;
        }

        Audit::enregistrer('devis.creation', 'devis', $id, [], $this->uid($requete));
        Response::succes((new Devis())->trouverAvecLignes($id), 'Devis enregistre.', 201);
    }

    /** PUT /api/v1/devis/{id}/statut  (change de statut : envoye / accepte / refuse) */
    public function changerStatut(Request $requete): void
    {
        $id = (int) $requete->params['id'];
        $modele = new Devis();
        if ($modele->trouver($id) === null) {
            Response::erreur('Devis introuvable.', 404);
        }
        $donnees = $this->valider($requete->tout(), ['statut' => 'requis|dans:brouillon,envoye,accepte,refuse']);
        $modele->modifier($id, ['statut' => $donnees['statut']]);
        Audit::enregistrer('devis.statut', 'devis', $id, ['statut' => $donnees['statut']], $this->uid($requete));
        Response::succes(null, 'Statut du devis mis a jour.');
    }

    /** POST /api/v1/devis/{id}/facturer : cree une facture a partir du devis. */
    public function facturer(Request $requete): void
    {
        $id = (int) $requete->params['id'];
        $devis = (new Devis())->trouverAvecLignes($id);
        if ($devis === null) {
            Response::erreur('Devis introuvable.', 404);
        }
        if ($devis['statut'] === 'refuse') {
            Response::erreur('Un devis refuse ne peut pas etre facture.', 409);
        }

        $entete = [
            'devis_id'     => $id,
            'client_id'    => $devis['client_id'],
            'chantier_id'  => $devis['chantier_id'],
            'date_facture' => date('Y-m-d'),
            'statut'       => 'brouillon',
            'notes'        => $devis['notes'],
            'cree_par'     => $this->uid($requete),
        ];
        $lignes = array_map(static fn ($l) => [
            'designation'   => $l['designation'],
            'quantite'      => $l['quantite'],
            'prix_unitaire' => $l['prix_unitaire'],
        ], $devis['lignes']);

        $factureId = (new Facture())->creerAvecLignes($entete, $lignes, (float) $devis['tva_taux']);
        (new Devis())->modifier($id, ['statut' => 'accepte']);

        Audit::enregistrer('devis.facturation', 'devis', $id, ['facture_id' => $factureId], $this->uid($requete));
        Response::succes((new Facture())->trouverAvecLignes($factureId), 'Facture creee a partir du devis.', 201);
    }

    /** DELETE /api/v1/devis/{id} */
    public function destroy(Request $requete): void
    {
        $id = (int) $requete->params['id'];
        $modele = new Devis();
        if ($modele->trouver($id) === null) {
            Response::erreur('Devis introuvable.', 404);
        }
        $modele->supprimer($id);
        Audit::enregistrer('devis.suppression', 'devis', $id, [], $this->uid($requete));
        Response::succes(null, 'Devis supprime.');
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
