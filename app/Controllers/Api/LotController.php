<?php

namespace App\Controllers\Api;

use App\Core\Audit;
use App\Core\Controller;
use App\Core\Request;
use App\Core\Response;
use App\Models\Chantier;
use App\Models\Lot;

/**
 * API des lots, imbriques sous un chantier.
 * Liste et creation via /chantiers/{id}/lots ; modification et suppression via /lots/{id}.
 */
final class LotController extends Controller
{
    private const REGLES = [
        'nom'                 => 'requis|longueur_max:150',
        'budget_previsionnel' => 'entier|min:0',
        'avancement'          => 'entier|min:0|max:100',
        'statut'              => 'dans:a_faire,en_cours,termine',
        'ordre'               => 'entier',
    ];

    private const CHAMPS = ['nom', 'budget_previsionnel', 'avancement', 'statut', 'ordre'];

    /** GET /api/v1/chantiers/{id}/lots */
    public function index(Request $requete): void
    {
        $chantierId = (int) $requete->params['id'];
        Response::succes((new Lot())->parChantier($chantierId), 'Lots du chantier');
    }

    /** POST /api/v1/chantiers/{id}/lots */
    public function store(Request $requete): void
    {
        $chantierId = (int) $requete->params['id'];
        if ((new Chantier())->trouver($chantierId) === null) {
            Response::erreur('Chantier introuvable.', 404);
        }

        $donnees = $this->valider($requete->tout(), self::REGLES);
        $valeurs = $this->filtrer($donnees);
        $valeurs['chantier_id'] = $chantierId;

        $lot = new Lot();
        $id = $lot->creer($valeurs);
        Audit::enregistrer('lot.creation', 'lot', $id, $valeurs, $this->uid($requete));

        Response::succes($lot->trouver($id), 'Lot ajoute.', 201);
    }

    /** PUT /api/v1/lots/{id} */
    public function update(Request $requete): void
    {
        $id = (int) $requete->params['id'];
        $lot = new Lot();
        if ($lot->trouver($id) === null) {
            Response::erreur('Lot introuvable.', 404);
        }

        $donnees = $this->valider($requete->tout(), self::REGLES);
        $valeurs = $this->filtrer($donnees);

        $lot->modifier($id, $valeurs);
        Audit::enregistrer('lot.modification', 'lot', $id, $valeurs, $this->uid($requete));

        Response::succes($lot->trouver($id), 'Lot modifie.');
    }

    /** DELETE /api/v1/lots/{id} */
    public function destroy(Request $requete): void
    {
        $id = (int) $requete->params['id'];
        $lot = new Lot();
        if ($lot->trouver($id) === null) {
            Response::erreur('Lot introuvable.', 404);
        }

        $lot->supprimer($id);
        Audit::enregistrer('lot.suppression', 'lot', $id, [], $this->uid($requete));

        Response::succes(null, 'Lot supprime.');
    }

    /** Ne garde que les champs autorises et convertit les chaines vides en NULL. */
    private function filtrer(array $donnees): array
    {
        $valeurs = array_intersect_key($donnees, array_flip(self::CHAMPS));
        foreach ($valeurs as $cle => $valeur) {
            if ($valeur === '') {
                $valeurs[$cle] = null;
            }
        }
        return $valeurs;
    }

    private function uid(Request $requete): ?int
    {
        return isset($requete->auth['sub']) ? (int) $requete->auth['sub'] : null;
    }
}
