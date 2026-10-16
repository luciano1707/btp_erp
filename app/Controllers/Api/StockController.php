<?php

namespace App\Controllers\Api;

use App\Core\Audit;
use App\Core\Controller;
use App\Core\Request;
use App\Core\Response;
use App\Models\Materiau;
use App\Models\MouvementStock;

/**
 * API du stock (Phase 5) : etat courant par materiau et enregistrement de mouvements
 * (notamment les sorties de materiaux consommes sur un chantier).
 */
final class StockController extends Controller
{
    /** GET /api/v1/stock : etat du stock (avec drapeau d'alerte de seuil). */
    public function index(Request $requete): void
    {
        $etat = (new MouvementStock())->etatStock();
        foreach ($etat as &$ligne) {
            $ligne['stock'] = (float) $ligne['stock'];
            $ligne['sous_seuil'] = $ligne['seuil_alerte'] !== null
                && $ligne['stock'] <= (float) $ligne['seuil_alerte'];
        }
        Response::succes($etat, 'Etat du stock');
    }

    /** GET /api/v1/materiaux/{id}/mouvements */
    public function historique(Request $requete): void
    {
        $materiauId = (int) $requete->params['id'];
        Response::succes((new MouvementStock())->historique($materiauId), 'Mouvements du materiau');
    }

    /** POST /api/v1/mouvements : enregistre un mouvement manuel (sortie chantier, ajustement...). */
    public function mouvement(Request $requete): void
    {
        $donnees = $this->valider($requete->tout(), [
            'materiau_id' => 'requis|entier',
            'type'        => 'requis|dans:entree,sortie,ajustement',
            'quantite'    => 'requis|numerique|min:0',
        ]);

        if ((new Materiau())->trouver((int) $donnees['materiau_id']) === null) {
            Response::erreur('Materiau introuvable.', 404);
        }

        $modele = new MouvementStock();
        $id = $modele->enregistrer([
            'materiau_id'    => (int) $donnees['materiau_id'],
            'type'           => $donnees['type'],
            'quantite'       => (float) $donnees['quantite'],
            'chantier_id'    => !empty($requete->input('chantier_id')) ? (int) $requete->input('chantier_id') : null,
            'motif'          => $requete->input('motif') ?: null,
            'date_mouvement' => $requete->input('date_mouvement') ?: date('Y-m-d'),
            'cree_par'       => isset($requete->auth['sub']) ? (int) $requete->auth['sub'] : null,
        ]);

        Audit::enregistrer('stock.mouvement', 'materiau', (int) $donnees['materiau_id'], [
            'type' => $donnees['type'], 'quantite' => $donnees['quantite'],
        ], isset($requete->auth['sub']) ? (int) $requete->auth['sub'] : null);

        Response::succes([
            'id'    => $id,
            'stock' => $modele->stock((int) $donnees['materiau_id']),
        ], 'Mouvement enregistre.', 201);
    }
}
