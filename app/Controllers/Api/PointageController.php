<?php

namespace App\Controllers\Api;

use App\Core\Audit;
use App\Core\Controller;
use App\Core\Request;
use App\Core\Response;
use App\Models\Chantier;
use App\Models\Employe;
use App\Models\Pointage;

/**
 * API de pointage de la main d'oeuvre (Phase 4).
 * Enregistrement par "feuille" (une date, plusieurs employes) ; le cout est calcule
 * a partir du taux journalier de l'employe et fige au moment de la saisie.
 */
final class PointageController extends Controller
{
    /** GET /api/v1/chantiers/{id}/pointages?date=YYYY-MM-DD */
    public function parChantier(Request $requete): void
    {
        $chantierId = (int) $requete->params['id'];
        $date = $requete->query('date');
        $lignes = (new Pointage())->feuille($chantierId, $date !== null ? (string) $date : null);
        if (!in_array($requete->auth['role'] ?? null, ['directeur', 'comptable'], true)) {
            $lignes = array_map(
                static fn (array $ligne): array => array_diff_key($ligne, ['cout' => true]),
                $lignes
            );
        }
        Response::succes($lignes, 'Pointages');
    }

    /**
     * POST /api/v1/chantiers/{id}/pointages
     * Corps : { "date": "YYYY-MM-DD", "lignes": [ { "employe_id":1, "type_presence":"journee", "lot_id":null } ] }
     */
    public function enregistrerFeuille(Request $requete): void
    {
        $chantierId = (int) $requete->params['id'];
        if ((new Chantier())->trouver($chantierId) === null) {
            Response::erreur('Chantier introuvable.', 404);
        }

        $donnees = $this->valider($requete->tout(), ['date' => 'requis']);
        $date = (string) $donnees['date'];
        $lignes = $requete->input('lignes', []);
        if (!is_array($lignes)) {
            Response::erreur('Le champ « lignes » doit etre une liste.', 422);
        }

        $modele = new Pointage();
        $employes = new Employe();
        $enregistres = 0;

        foreach ($lignes as $ligne) {
            $employeId = (int) ($ligne['employe_id'] ?? 0);
            if ($employeId === 0) {
                continue;
            }
            $employe = $employes->trouver($employeId);
            if ($employe === null) {
                continue;
            }

            $type = (string) ($ligne['type_presence'] ?? 'journee');
            if (!isset(Pointage::COEFFICIENTS[$type])) {
                $type = 'journee';
            }
            $lotId = !empty($ligne['lot_id']) ? (int) $ligne['lot_id'] : null;

            $cout = (int) round(((int) $employe['taux_journalier']) * Pointage::COEFFICIENTS[$type]);

            $modele->enregistrerLigne($chantierId, $lotId, $employeId, $date, $type, $cout, $this->uid($requete));
            $enregistres++;
        }

        Audit::enregistrer('pointage.feuille', 'chantier', $chantierId, ['date' => $date, 'lignes' => $enregistres], $this->uid($requete));
        Response::succes(['enregistres' => $enregistres, 'date' => $date], 'Feuille de pointage enregistree.');
    }

    /** DELETE /api/v1/pointages/{id} */
    public function destroy(Request $requete): void
    {
        $id = (int) $requete->params['id'];
        $modele = new Pointage();
        if ($modele->trouver($id) === null) {
            Response::erreur('Pointage introuvable.', 404);
        }
        $modele->supprimer($id);
        Audit::enregistrer('pointage.suppression', 'pointage', $id, [], $this->uid($requete));
        Response::succes(null, 'Pointage supprime.');
    }

    private function uid(Request $requete): ?int
    {
        return isset($requete->auth['sub']) ? (int) $requete->auth['sub'] : null;
    }
}
