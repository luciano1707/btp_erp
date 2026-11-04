<?php

namespace App\Controllers\Api;

use App\Core\Audit;
use App\Core\Controller;
use App\Core\Request;
use App\Core\Response;
use App\Models\Notification;
use App\Models\Rfi;

final class RfiController extends Controller
{
    /** GET /api/v1/rfi */
    public function index(Request $requete): void
    {
        $filtre = [
            'chantier_id' => $requete->query('chantier_id'),
            'statut'      => $requete->query('statut'),
            'priorite'    => $requete->query('priorite'),
        ];
        Response::succes((new Rfi())->liste($filtre), 'Liste des RFI');
    }

    /** GET /api/v1/rfi/{id} */
    public function show(Request $requete): void
    {
        $rfi = (new Rfi())->trouverAvecDetails((int) $requete->params['id']);
        if ($rfi === null) {
            Response::erreur('RFI introuvable.', 404);
        }
        Response::succes($rfi);
    }

    /** POST /api/v1/rfi */
    public function store(Request $requete): void
    {
        $this->valider($requete->tout(), [
            'chantier_id' => 'requis|entier',
            'objet'       => 'requis|longueur_max:150',
            'question'    => 'requis',
        ]);

        $priorite = $requete->input('priorite', 'normale');
        if (!in_array($priorite, ['basse', 'normale', 'haute', 'critique'], true)) {
            $priorite = 'normale';
        }

        $id = (new Rfi())->creer([
            'numero'      => Rfi::genererNumero(),
            'chantier_id' => (int) $requete->input('chantier_id'),
            'emetteur_id' => $this->uid($requete),
            'objet'       => $requete->input('objet'),
            'question'    => $requete->input('question'),
            'priorite'    => $priorite,
            'date_limite' => $requete->input('date_limite') ?: null,
            'statut'      => 'ouvert',
        ]);

        Audit::enregistrer('rfi.creation', 'rfi', $id, [], $this->uid($requete));
        Notification::pourRoles(
            ['directeur', 'chef_chantier'],
            'rfi',
            'Nouvelle RFI',
            'RFI ' . $requete->input('objet') . ' en attente de reponse.',
            '/rfi/' . $id
        );
        Response::succes((new Rfi())->trouverAvecDetails($id), 'RFI creee.', 201);
    }

    /** POST /api/v1/rfi/{id}/repondre */
    public function repondre(Request $requete): void
    {
        $this->valider($requete->tout(), ['reponse' => 'requis']);
        $id = (int) $requete->params['id'];
        $modele = new Rfi();
        $rfi = $modele->trouverAvecDetails($id);
        if ($rfi === null) {
            Response::erreur('RFI introuvable.', 404);
        }

        $uid = $this->uid($requete);
        $modele->repondre($id, $uid, (string) $requete->input('reponse'));
        Audit::enregistrer('rfi.reponse', 'rfi', $id, [], $uid);
        Notification::creer(
            (int) $rfi['emetteur_id'],
            'rfi',
            'RFI repondue',
            'Une reponse a ete apportee a la RFI ' . $rfi['numero'] . '.',
            '/rfi/' . $id
        );
        Response::succes($modele->trouverAvecDetails($id), 'Reponse enregistree.');
    }

    private function uid(Request $requete): ?int
    {
        return isset($requete->auth['sub']) ? (int) $requete->auth['sub'] : null;
    }
}
