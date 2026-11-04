<?php

namespace App\Controllers\Api;

use App\Core\Audit;
use App\Core\Controller;
use App\Core\Request;
use App\Core\Response;
use App\Core\ValidationService;
use App\Models\Devis;
use App\Models\Facture;
use RuntimeException;

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

    /**
     * PUT /api/v1/devis/{id}/statut
     * Les transitions envoye / accepte / refuse passent par le workflow central
     * (soumission puis decision), afin d'empecher toute validation directe.
     */
    public function changerStatut(Request $requete): void
    {
        $id = (int) $requete->params['id'];
        $modele = new Devis();
        $devis = $modele->trouver($id);
        if ($devis === null) {
            Response::erreur('Devis introuvable.', 404);
        }
        $donnees = $this->valider($requete->tout(), ['statut' => 'requis|dans:brouillon,envoye,accepte,refuse']);
        $statut = (string) $donnees['statut'];

        if ($statut === 'brouillon') {
            if (!in_array($devis['statut'], ['brouillon', 'refuse'], true)) {
                Response::erreur('Un devis valide ne peut pas revenir en brouillon.', 409);
            }
            $modele->modifier($id, ['statut' => 'brouillon']);
            Response::succes(null, 'Devis remis en brouillon.');
        }

        $service = new ValidationService();
        try {
            $validation = $service->trouverParOperation('devis', $id);
            $soumetteur = (int) ($devis['cree_par'] ?? 0);
            if ($validation === null || $validation['statut'] !== 'en_attente') {
                if (in_array($devis['statut'], ['accepte', 'refuse'], true)) {
                    Response::erreur('Ce devis a deja fait l\'objet d\'une decision.', 409);
                }
                $validation = $service->soumettre([
                    'type_operation' => 'devis',
                    'operation_id' => $id,
                    'soumetteur_id' => $soumetteur,
                ]);
            }

            if ($statut === 'envoye') {
                Response::succes($validation, 'Devis soumis au directeur.');
            }

            $service->decider(
                (int) $validation['id'],
                (int) $this->uid($requete),
                (string) ($requete->auth['role'] ?? ''),
                $statut === 'accepte',
                $statut === 'refuse' ? 'Refus commercial du devis' : null
            );
        } catch (RuntimeException $e) {
            $code = str_contains($e->getMessage(), 'auto-validation') || str_contains($e->getMessage(), 'autorise')
                ? 403
                : 409;
            Response::erreur($e->getMessage(), $code);
        }

        Response::succes($modele->trouver($id), 'Statut du devis mis a jour.');
    }

    /** POST /api/v1/devis/{id}/soumettre - soumission au directeur. */
    public function soumettre(Request $requete): void
    {
        $id = (int) $requete->params['id'];
        $devis = (new Devis())->trouver($id);
        if ($devis === null) {
            Response::erreur('Devis introuvable.', 404);
        }
        if (!in_array($devis['statut'], ['brouillon', 'refuse'], true)) {
            Response::erreur('Ce devis ne peut pas etre soumis dans son etat actuel.', 409);
        }

        try {
            $validation = (new ValidationService())->soumettre([
                'type_operation' => 'devis',
                'operation_id' => $id,
                'soumetteur_id' => $this->uid($requete),
            ]);
        } catch (RuntimeException $e) {
            Response::erreur($e->getMessage(), 409);
        }

        Response::succes($validation, 'Devis soumis au directeur.');
    }

    /** POST /api/v1/devis/{id}/facturer : cree une facture a partir du devis. */
    public function facturer(Request $requete): void
    {
        $id = (int) $requete->params['id'];
        $devis = (new Devis())->trouverAvecLignes($id);
        if ($devis === null) {
            Response::erreur('Devis introuvable.', 404);
        }
        $valide = ($devis['statut'] ?? '') === 'accepte'
            || (new ValidationService())->estValidee('devis', $id);
        if (!$valide) {
            Response::erreur('Seul un devis valide par le directeur peut etre facture.', 409);
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
