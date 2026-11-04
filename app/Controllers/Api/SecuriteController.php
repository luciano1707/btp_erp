<?php

namespace App\Controllers\Api;

use App\Core\Audit;
use App\Core\Controller;
use App\Core\Request;
use App\Core\Response;
use App\Models\Notification;
use App\Models\Securite;

final class SecuriteController extends Controller
{
    /** GET /api/v1/securite */
    public function index(Request $requete): void
    {
        $filtre = [
            'chantier_id'      => $requete->query('chantier_id'),
            'statut'           => $requete->query('statut'),
            'type_observation' => $requete->query('type_observation'),
        ];
        Response::succes((new Securite())->liste($filtre), 'Liste des observations securite');
    }

    /** GET /api/v1/securite/{id} */
    public function show(Request $requete): void
    {
        $observation = (new Securite())->trouverAvecDetails((int) $requete->params['id']);
        if ($observation === null) {
            Response::erreur('Observation introuvable.', 404);
        }
        Response::succes($observation);
    }

    /** POST /api/v1/securite */
    public function store(Request $requete): void
    {
        $this->valider($requete->tout(), [
            'chantier_id'      => 'requis|entier',
            'date_observation' => 'requis',
            'description'      => 'requis',
        ]);

        $type = $requete->input('type_observation', 'danger');
        if (!in_array($type, ['danger', 'risque', 'bonne_pratique', 'autre'], true)) {
            $type = 'danger';
        }

        $id = (new Securite())->creer([
            'numero'            => Securite::genererNumero(),
            'chantier_id'       => (int) $requete->input('chantier_id'),
            'declarant_id'      => $this->uid($requete),
            'date_observation'  => $requete->input('date_observation'),
            'lieu'              => $requete->input('lieu'),
            'type_observation'  => $type,
            'description'       => $requete->input('description'),
            'action_immediate'  => $requete->input('action_immediate'),
            'mesure_preventive' => $requete->input('mesure_preventive'),
            'statut'            => 'ouvert',
        ]);

        Audit::enregistrer('securite.creation', 'securite', $id, [], $this->uid($requete));
        if (in_array($type, ['danger', 'risque'], true)) {
            Notification::pourRoles(
                ['directeur', 'chef_chantier'],
                'securite',
                'Observation securite a traiter',
                'Une observation de type ' . $type . ' a ete signalee.',
                '/securite/' . $id
            );
        }
        Response::succes((new Securite())->trouverAvecDetails($id), 'Observation securite creee.', 201);
    }

    /** PUT /api/v1/securite/{id} */
    public function update(Request $requete): void
    {
        $id = (int) $requete->params['id'];
        $modele = new Securite();
        $observation = $modele->trouverAvecDetails($id);
        if ($observation === null) {
            Response::erreur('Observation introuvable.', 404);
        }

        $donnees = [];
        foreach (['lieu', 'type_observation', 'description', 'action_immediate', 'mesure_preventive', 'statut'] as $champ) {
            if ($requete->input($champ) !== null) {
                $donnees[$champ] = $requete->input($champ);
            }
        }
        if ($donnees === []) {
            Response::erreur('Aucune modification fournie.', 422);
        }

        $modele->modifier($id, $donnees);
        Audit::enregistrer('securite.modification', 'securite', $id, [], $this->uid($requete));
        Response::succes($modele->trouverAvecDetails($id), 'Observation mise a jour.');
    }

    private function uid(Request $requete): ?int
    {
        return isset($requete->auth['sub']) ? (int) $requete->auth['sub'] : null;
    }
}
