<?php

namespace App\Controllers\Api;

use App\Core\Audit;
use App\Core\Controller;
use App\Core\Request;
use App\Core\Response;
use App\Models\Budget;
use PDOException;

final class BudgetController extends Controller
{
    /** GET /api/v1/budgets */
    public function index(Request $requete): void
    {
        $filtre = [
            'chantier_id' => $requete->query('chantier_id'),
            'annee'       => $requete->query('annee'),
            'statut'      => $requete->query('statut'),
        ];
        Response::succes((new Budget())->liste($filtre), 'Liste des budgets');
    }

    /** GET /api/v1/budgets/{id} */
    public function show(Request $requete): void
    {
        $budget = (new Budget())->trouverAvecLignes((int) $requete->params['id']);
        if ($budget === null) {
            Response::erreur('Budget introuvable.', 404);
        }
        Response::succes($budget);
    }

    /** POST /api/v1/budgets */
    public function store(Request $requete): void
    {
        $this->valider($requete->tout(), [
            'chantier_id' => 'requis|entier',
            'annee'       => 'requis|entier|min:2000|max:2100',
        ]);

        $lignes = $this->lignes($requete->input('lignes', []));
        $previsionnel = $requete->input('budget_previsionnel');
        if ($previsionnel === null || $previsionnel === '') {
            $previsionnel = array_sum(array_column($lignes, 'montant_prevu'));
        }

        try {
            $id = (new Budget())->creerAvecLignes([
                'chantier_id'         => (int) $requete->input('chantier_id'),
                'annee'               => (int) $requete->input('annee'),
                'budget_previsionnel' => $previsionnel,
                'budget_revision'     => $requete->input('budget_revision', 0),
                'devise'              => $requete->input('devise', 'MGA'),
                'statut'              => $requete->input('statut', 'ouvert'),
                'notes'               => $requete->input('notes'),
                'cree_par'            => $this->uid($requete),
            ], $lignes);
        } catch (PDOException $e) {
            if ($e->getCode() === '23000') {
                Response::erreur('Un budget existe deja pour ce chantier et cette annee.', 422);
            }
            throw $e;
        }

        Audit::enregistrer('budget.creation', 'budget', $id, [], $this->uid($requete));
        Response::succes((new Budget())->trouverAvecLignes($id), 'Budget cree.', 201);
    }

    /** PUT /api/v1/budgets/{id} */
    public function update(Request $requete): void
    {
        $id = (int) $requete->params['id'];
        $modele = new Budget();
        $budget = $modele->trouverAvecLignes($id);
        if ($budget === null) {
            Response::erreur('Budget introuvable.', 404);
        }

        $entete = [];
        foreach (['budget_previsionnel', 'budget_revision', 'devise', 'statut', 'notes'] as $champ) {
            if ($requete->input($champ) !== null) {
                $entete[$champ] = $requete->input($champ);
            }
        }
        if ($entete === [] && $requete->input('lignes') === null) {
            Response::erreur('Aucune modification fournie.', 422);
        }

        $lignes = $requete->input('lignes');
        $modele->modifierAvecLignes($id, $entete, $lignes === null ? null : $this->lignes($lignes));
        Audit::enregistrer('budget.modification', 'budget', $id, [], $this->uid($requete));
        Response::succes($modele->trouverAvecLignes($id), 'Budget mis a jour.');
    }

    /**
     * @param mixed $lignes
     * @return array<int,array<string,mixed>>
     */
    private function lignes(mixed $lignes): array
    {
        if (!is_array($lignes)) {
            return [];
        }
        $propres = [];
        foreach ($lignes as $ligne) {
            if (!is_array($ligne) || empty($ligne['rubrique'])) {
                continue;
            }
            $propres[] = [
                'rubrique'       => mb_substr((string) $ligne['rubrique'], 0, 80),
                'montant_prevu'  => (float) ($ligne['montant_prevu'] ?? 0),
                'montant_engage' => (float) ($ligne['montant_engage'] ?? 0),
                'montant_reel'   => (float) ($ligne['montant_reel'] ?? 0),
            ];
        }
        return $propres;
    }

    private function uid(Request $requete): ?int
    {
        return isset($requete->auth['sub']) ? (int) $requete->auth['sub'] : null;
    }
}
