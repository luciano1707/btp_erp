<?php

namespace App\Controllers\Api;

use App\Core\Audit;
use App\Core\Controller;
use App\Core\Request;
use App\Core\Response;
use App\Models\Achat;
use App\Models\MouvementStock;

/**
 * API des achats (Phase 5). En-tete + lignes crees ensemble ;
 * la reception genere les entrees de stock correspondantes.
 */
final class AchatController extends Controller
{
    private const CHAMPS_ENTETE = ['reference', 'fournisseur_id', 'chantier_id', 'date_achat', 'notes'];

    /** GET /api/v1/achats?page=&limite=&recherche= */
    public function index(Request $requete): void
    {
        $limite   = max(1, min((int) $requete->query('limite', 50), 200));
        $page     = max(1, (int) $requete->query('page', 1));
        $terme    = (string) $requete->query('recherche', '');
        $resultat = (new Achat())->liste($terme, $limite, ($page - 1) * $limite);

        Response::succes([
            'elements' => $resultat['lignes'],
            'total'    => $resultat['total'],
            'page'     => $page,
            'limite'   => $limite,
        ], 'Liste des achats');
    }

    /** GET /api/v1/achats/{id} */
    public function show(Request $requete): void
    {
        $achat = (new Achat())->trouverAvecLignes((int) $requete->params['id']);
        if ($achat === null) {
            Response::erreur('Achat introuvable.', 404);
        }
        Response::succes($achat);
    }

    /** POST /api/v1/achats */
    public function store(Request $requete): void
    {
        $this->valider($requete->tout(), [
            'date_achat' => 'requis',
        ]);

        $lignes = $requete->input('lignes', []);
        if (!is_array($lignes) || $lignes === []) {
            Response::erreur('Au moins une ligne d\'achat est requise.', 422);
        }

        $entete = $this->filtrerEntete($requete->tout());
        $entete['statut'] = 'commande';
        $entete['cree_par'] = $this->uid($requete);

        try {
            $id = (new Achat())->creerAvecLignes($entete, $lignes);
        } catch (\PDOException $e) {
            if ($e->getCode() === '23000') {
                Response::erreur('Reference d\'achat deja utilisee.', 422);
            }
            throw $e;
        }

        Audit::enregistrer('achat.creation', 'achat', $id, ['montant' => null], $this->uid($requete));
        Response::succes((new Achat())->trouverAvecLignes($id), 'Achat enregistre.', 201);
    }

    /** POST /api/v1/achats/{id}/reception : passe l'achat en "recu" et cree les entrees de stock. */
    public function reception(Request $requete): void
    {
        $id = (int) $requete->params['id'];
        $modele = new Achat();
        $achat = $modele->trouverAvecLignes($id);
        if ($achat === null) {
            Response::erreur('Achat introuvable.', 404);
        }
        if ($achat['statut'] === 'recu') {
            Response::erreur('Cet achat a deja ete receptionne.', 409);
        }
        if ($achat['statut'] === 'annule') {
            Response::erreur('Un achat annule ne peut pas etre receptionne.', 409);
        }

        $mouvement = new MouvementStock();
        $date = $achat['date_achat'] ?: date('Y-m-d');
        $nbEntrees = 0;
        foreach ($achat['lignes'] as $ligne) {
            if (empty($ligne['materiau_id'])) {
                continue; // ligne libre sans materiau catalogue : pas de mouvement de stock
            }
            $mouvement->enregistrer([
                'materiau_id'    => (int) $ligne['materiau_id'],
                'type'           => 'entree',
                'quantite'       => $ligne['quantite'],
                'chantier_id'    => $achat['chantier_id'],
                'achat_id'       => $id,
                'motif'          => 'Reception achat ' . ($achat['reference'] ?? "#$id"),
                'date_mouvement' => $date,
                'cree_par'       => $this->uid($requete),
            ]);
            $nbEntrees++;
        }

        $modele->modifier($id, ['statut' => 'recu']);
        Audit::enregistrer('achat.reception', 'achat', $id, ['entrees_stock' => $nbEntrees], $this->uid($requete));

        Response::succes(['entrees_stock' => $nbEntrees], 'Achat receptionne : stock mis a jour.');
    }

    /** POST /api/v1/achats/{id}/annuler */
    public function annuler(Request $requete): void
    {
        $id = (int) $requete->params['id'];
        $modele = new Achat();
        $achat = $modele->trouver($id);
        if ($achat === null) {
            Response::erreur('Achat introuvable.', 404);
        }
        if ($achat['statut'] === 'recu') {
            Response::erreur('Un achat deja receptionne ne peut pas etre annule (le stock a ete impacte).', 409);
        }
        $modele->modifier($id, ['statut' => 'annule']);
        Audit::enregistrer('achat.annulation', 'achat', $id, [], $this->uid($requete));
        Response::succes(null, 'Achat annule.');
    }

    /** DELETE /api/v1/achats/{id} */
    public function destroy(Request $requete): void
    {
        $id = (int) $requete->params['id'];
        $modele = new Achat();
        if ($modele->trouver($id) === null) {
            Response::erreur('Achat introuvable.', 404);
        }
        $modele->supprimer($id); // les lignes sont supprimees en cascade
        Audit::enregistrer('achat.suppression', 'achat', $id, [], $this->uid($requete));
        Response::succes(null, 'Achat supprime.');
    }

    private function filtrerEntete(array $donnees): array
    {
        $entete = array_intersect_key($donnees, array_flip(self::CHAMPS_ENTETE));
        foreach ($entete as $cle => $valeur) {
            if ($valeur === '') {
                $entete[$cle] = null;
            }
        }
        return $entete;
    }

    private function uid(Request $requete): ?int
    {
        return isset($requete->auth['sub']) ? (int) $requete->auth['sub'] : null;
    }
}
