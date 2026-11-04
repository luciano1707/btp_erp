<?php

namespace App\Controllers\Api;

use App\Core\Audit;
use App\Core\Controller;
use App\Core\Request;
use App\Core\Response;
use App\Models\Notification;
use App\Models\Qualite;

final class QualiteController extends Controller
{
    /** GET /api/v1/qualite */
    public function index(Request $requete): void
    {
        $filtre = [
            'chantier_id' => $requete->query('chantier_id'),
            'statut'      => $requete->query('statut'),
            'resultat'    => $requete->query('resultat'),
        ];
        Response::succes((new Qualite())->liste($filtre), 'Liste des inspections qualite');
    }

    /** GET /api/v1/qualite/{id} */
    public function show(Request $requete): void
    {
        $inspection = (new Qualite())->trouverAvecDetails((int) $requete->params['id']);
        if ($inspection === null) {
            Response::erreur('Inspection introuvable.', 404);
        }
        Response::succes($inspection);
    }

    /** POST /api/v1/qualite */
    public function store(Request $requete): void
    {
        $this->valider($requete->tout(), [
            'chantier_id'     => 'requis|entier',
            'date_inspection' => 'requis',
        ]);

        $resultat = $requete->input('resultat', 'conforme');
        if (!in_array($resultat, ['conforme', 'non_conforme', 'reserve'], true)) {
            $resultat = 'conforme';
        }

        $id = (new Qualite())->creer([
            'numero'            => Qualite::genererNumero(),
            'chantier_id'       => (int) $requete->input('chantier_id'),
            'inspecteur_id'     => $this->uid($requete),
            'lot_id'            => $requete->input('lot_id') ?: null,
            'date_inspection'   => $requete->input('date_inspection'),
            'type_inspection'   => $requete->input('type_inspection'),
            'resultat'          => $resultat,
            'constat'           => $requete->input('constat'),
            'action_corrective' => $requete->input('action_corrective'),
            'statut'            => 'ouvert',
        ]);

        Audit::enregistrer('qualite.creation', 'qualite', $id, [], $this->uid($requete));
        if ($resultat !== 'conforme') {
            Notification::pourRoles(
                ['directeur', 'chef_chantier'],
                'qualite',
                'Non-conformite signalee',
                'Une inspection qualite a ete classee ' . $resultat . '.',
                '/qualite/' . $id
            );
        }
        Response::succes((new Qualite())->trouverAvecDetails($id), 'Inspection qualite creee.', 201);
    }

    /** PUT /api/v1/qualite/{id} */
    public function update(Request $requete): void
    {
        $id = (int) $requete->params['id'];
        $modele = new Qualite();
        $inspection = $modele->trouverAvecDetails($id);
        if ($inspection === null) {
            Response::erreur('Inspection introuvable.', 404);
        }

        $donnees = [];
        foreach (['lot_id', 'type_inspection', 'resultat', 'constat', 'action_corrective', 'statut'] as $champ) {
            if ($requete->input($champ) !== null) {
                $donnees[$champ] = $requete->input($champ);
            }
        }
        if ($donnees === []) {
            Response::erreur('Aucune modification fournie.', 422);
        }

        $modele->modifier($id, $donnees);
        Audit::enregistrer('qualite.modification', 'qualite', $id, [], $this->uid($requete));
        Response::succes($modele->trouverAvecDetails($id), 'Inspection mise a jour.');
    }

    private function uid(Request $requete): ?int
    {
        return isset($requete->auth['sub']) ? (int) $requete->auth['sub'] : null;
    }
}
