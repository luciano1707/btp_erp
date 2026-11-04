<?php

namespace App\Controllers\Api;

use App\Core\Audit;
use App\Core\Controller;
use App\Core\Request;
use App\Core\Response;
use App\Models\Incident;
use App\Models\Notification;

final class IncidentController extends Controller
{
    /** GET /api/v1/incidents */
    public function index(Request $requete): void
    {
        $filtre = [
            'chantier_id'   => $requete->query('chantier_id'),
            'statut'        => $requete->query('statut'),
            'gravite'       => $requete->query('gravite'),
            'type_incident' => $requete->query('type_incident'),
        ];
        Response::succes((new Incident())->liste($filtre), 'Liste des incidents');
    }

    /** GET /api/v1/incidents/{id} */
    public function show(Request $requete): void
    {
        $incident = (new Incident())->trouverAvecDetails((int) $requete->params['id']);
        if ($incident === null) {
            Response::erreur('Incident introuvable.', 404);
        }
        Response::succes($incident);
    }

    /** POST /api/v1/incidents */
    public function store(Request $requete): void
    {
        $this->valider($requete->tout(), [
            'chantier_id'   => 'requis|entier',
            'date_incident' => 'requis',
            'description'   => 'requis',
        ]);

        $gravite = $requete->input('gravite', 'faible');
        if (!in_array($gravite, ['faible', 'moyenne', 'grave', 'critique'], true)) {
            $gravite = 'faible';
        }
        $type = $requete->input('type_incident', 'incident');
        if (!in_array($type, ['incident', 'accident', 'presque_accident'], true)) {
            $type = 'incident';
        }

        $id = (new Incident())->creer([
            'numero'            => Incident::genererNumero(),
            'chantier_id'       => (int) $requete->input('chantier_id'),
            'declarant_id'      => $this->uid($requete),
            'date_incident'     => $this->normaliserDate((string) $requete->input('date_incident')),
            'lieu'              => $requete->input('lieu'),
            'type_incident'     => $type,
            'gravite'           => $gravite,
            'victimes'          => $requete->input('victimes'),
            'description'       => $requete->input('description'),
            'premiers_secours'  => $requete->input('premiers_secours'),
            'action_corrective' => $requete->input('action_corrective'),
            'statut'            => 'ouvert',
        ]);

        Audit::enregistrer('incident.creation', 'incident', $id, [], $this->uid($requete));
        Notification::pourRoles(
            ['directeur', 'chef_chantier'],
            'incident',
            'Incident declare',
            ucfirst(str_replace('_', ' ', $type)) . ' de gravite ' . $gravite . ' signale.',
            '/incidents/' . $id
        );
        Response::succes((new Incident())->trouverAvecDetails($id), 'Incident declare.', 201);
    }

    /** PUT /api/v1/incidents/{id} */
    public function update(Request $requete): void
    {
        $id = (int) $requete->params['id'];
        $modele = new Incident();
        $incident = $modele->trouverAvecDetails($id);
        if ($incident === null) {
            Response::erreur('Incident introuvable.', 404);
        }

        $donnees = [];
        foreach (['lieu', 'type_incident', 'gravite', 'victimes', 'description',
                  'premiers_secours', 'action_corrective', 'statut', 'suivi_par'] as $champ) {
            if ($requete->input($champ) !== null) {
                $donnees[$champ] = $requete->input($champ);
            }
        }
        if ($donnees === []) {
            Response::erreur('Aucune modification fournie.', 422);
        }

        $modele->modifier($id, $donnees);
        Audit::enregistrer('incident.modification', 'incident', $id, [], $this->uid($requete));
        Response::succes($modele->trouverAvecDetails($id), 'Incident mis a jour.');
    }

    private function normaliserDate(string $valeur): string
    {
        $valeur = str_replace('T', ' ', trim($valeur));
        if (strlen($valeur) === 16) {
            $valeur .= ':00';
        }
        return $valeur;
    }

    private function uid(Request $requete): ?int
    {
        return isset($requete->auth['sub']) ? (int) $requete->auth['sub'] : null;
    }
}
