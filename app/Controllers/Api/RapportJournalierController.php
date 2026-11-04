<?php

namespace App\Controllers\Api;

use App\Core\Audit;
use App\Core\Controller;
use App\Core\Request;
use App\Core\Response;
use App\Models\RapportJournalier;
use PDOException;

final class RapportJournalierController extends Controller
{
    /** GET /api/v1/rapports-journaliers */
    public function index(Request $requete): void
    {
        $donnees = (new RapportJournalier())->liste();
        Response::succes($donnees, 'Liste des rapports journaliers');
    }

    /** GET /api/v1/rapports-journaliers/{id} */
    public function show(Request $requete): void
    {
        $rapport = (new RapportJournalier())->trouverAvecDetails((int) $requete->params['id']);
        if ($rapport === null) {
            Response::erreur('Rapport introuvable.', 404);
        }
        Response::succes($rapport);
    }

    /** POST /api/v1/rapports-journaliers */
    public function store(Request $requete): void
    {
        $this->valider($requete->tout(), [
            'chantier_id'  => 'requis',
            'date_rapport' => 'requis',
        ]);

        $donnees = [
            'numero'           => RapportJournalier::genererNumero(),
            'chantier_id'      => (int) $requete->input('chantier_id'),
            'chef_chantier_id' => $this->uid($requete),
            'date_rapport'     => $requete->input('date_rapport'),
            'meteo'            => $requete->input('meteo'),
            'travaux_realises' => $requete->input('travaux_realises', $requete->input('travaux_effectues')),
            'avancement_pct'   => $this->pourcentage($requete->input('avancement_pct')),
            'problemes'        => $requete->input('problemes'),
            'incidents'        => $requete->input('incidents'),
            'observations'     => $requete->input('observations'),
            'statut'           => 'brouillon',
        ];

        try {
            $id = (new RapportJournalier())->creer($donnees);
        } catch (PDOException $e) {
            if ($e->getCode() === '23000') {
                Response::erreur('Un rapport existe déjà pour ce chantier à cette date.', 422);
            }
            throw $e;
        }

        Audit::enregistrer('rapport_journalier.creation', 'rapport_journalier', $id, [], $this->uid($requete));
        Response::succes((new RapportJournalier())->trouverAvecDetails($id), 'Rapport créé.', 201);
    }

    /** PUT /api/v1/rapports-journaliers/{id} */
    public function update(Request $requete): void
    {
        $id = (int) $requete->params['id'];
        $modele = new RapportJournalier();
        if ($modele->trouver($id) === null) {
            Response::erreur('Rapport introuvable.', 404);
        }

        $donnees = [];
        $correspondances = [
            'date_rapport'     => 'date_rapport',
            'meteo'            => 'meteo',
            'travaux_realises' => 'travaux_realises',
            'travaux_effectues'=> 'travaux_realises',
            'problemes'        => 'problemes',
            'incidents'        => 'incidents',
            'observations'     => 'observations',
        ];
        $tout = $requete->tout();
        foreach ($correspondances as $source => $colonne) {
            if (array_key_exists($source, $tout)) {
                $donnees[$colonne] = $tout[$source];
            }
        }
        if (array_key_exists('avancement_pct', $tout)) {
            $donnees['avancement_pct'] = $this->pourcentage($tout['avancement_pct']);
        }

        if ($donnees === []) {
            Response::erreur('Aucune donnée à mettre à jour.', 422);
        }

        $modele->modifier($id, $donnees);
        Audit::enregistrer('rapport_journalier.modification', 'rapport_journalier', $id, [], $this->uid($requete));
        Response::succes($modele->trouverAvecDetails($id), 'Rapport mis à jour.');
    }

    /** POST /api/v1/rapports-journaliers/{id}/soumettre */
    public function soumettre(Request $requete): void
    {
        $id = (int) $requete->params['id'];
        $modele = new RapportJournalier();
        if ($modele->trouver($id) === null) {
            Response::erreur('Rapport introuvable.', 404);
        }
        $modele->modifier($id, [
            'statut'    => 'soumis',
            'soumis_le' => date('Y-m-d H:i:s'),
        ]);
        Audit::enregistrer('rapport_journalier.soumission', 'rapport_journalier', $id, [], $this->uid($requete));
        Response::succes($modele->trouverAvecDetails($id), 'Rapport soumis.');
    }

    private function pourcentage(mixed $valeur): ?int
    {
        if ($valeur === null || $valeur === '') {
            return null;
        }
        return max(0, min(100, (int) $valeur));
    }

    private function uid(Request $requete): ?int
    {
        return isset($requete->auth['sub']) ? (int) $requete->auth['sub'] : null;
    }
}
