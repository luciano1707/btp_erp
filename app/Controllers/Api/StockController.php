<?php

namespace App\Controllers\Api;

use App\Core\Audit;
use App\Core\Controller;
use App\Core\Request;
use App\Core\Response;
use App\Core\ValidationService;
use App\Models\Materiau;
use App\Models\MouvementStock;
use RuntimeException;

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
            'quantite'    => 'requis|numerique|min:0.001',
        ]);

        if ((new Materiau())->trouver((int) $donnees['materiau_id']) === null) {
            Response::erreur('Materiau introuvable.', 404);
        }

        $modele = new MouvementStock();
        $materiauId = (int) $donnees['materiau_id'];
        $stockActuel = $modele->stock($materiauId);
        $exceptionnelle = $donnees['type'] === 'sortie'
            && (float) $donnees['quantite'] > $stockActuel;

        $id = $modele->enregistrer([
            'materiau_id'    => $materiauId,
            'type'           => $donnees['type'],
            'quantite'       => (float) $donnees['quantite'],
            'chantier_id'    => !empty($requete->input('chantier_id')) ? (int) $requete->input('chantier_id') : null,
            'motif'          => $requete->input('motif') ?: null,
            'statut'         => $exceptionnelle ? 'en_attente' : 'valide',
            'date_mouvement' => $requete->input('date_mouvement') ?: date('Y-m-d'),
            'cree_par'       => isset($requete->auth['sub']) ? (int) $requete->auth['sub'] : null,
        ]);

        if ($exceptionnelle) {
            try {
                (new ValidationService())->soumettre([
                    'type_operation' => 'sortie_stock',
                    'operation_id' => $id,
                    'soumetteur_id' => isset($requete->auth['sub']) ? (int) $requete->auth['sub'] : 0,
                ]);
            } catch (RuntimeException $e) {
                $modele->supprimer($id);
                Response::erreur($e->getMessage(), 409);
            }
        }

        Audit::enregistrer('stock.mouvement', 'materiau', $materiauId, [
            'type' => $donnees['type'], 'quantite' => $donnees['quantite'],
            'exceptionnelle' => $exceptionnelle,
        ], isset($requete->auth['sub']) ? (int) $requete->auth['sub'] : null);

        Response::succes([
            'id'    => $id,
            'stock' => $modele->stock($materiauId),
        ], $exceptionnelle
            ? 'Sortie exceptionnelle soumise a la validation du directeur.'
            : 'Mouvement enregistre.', $exceptionnelle ? 202 : 201);
    }
}
