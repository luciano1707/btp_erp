<?php

namespace App\Controllers\Api;

use App\Core\Request;
use App\Core\ResourceController;
use App\Core\Response;
use App\Core\Access;
use App\Models\Achat;
use App\Models\Chantier;
use App\Models\Lot;
use App\Models\Pointage;

/**
 * API CRUD des chantiers.
 * Herite du CRUD generique ; surcharge index/show pour joindre client + responsable
 * et calculer les statistiques d'avancement a partir des lots.
 */
final class ChantierController extends ResourceController
{
    protected string $entite = 'chantier';
    protected string $modulePermission = 'chantiers';
    protected array $champs = [
        'code', 'nom', 'type', 'client_id', 'responsable_id', 'localisation',
        'date_debut', 'date_fin_prevue', 'date_fin_reelle', 'budget_previsionnel',
        'statut', 'description', 'actif',
    ];
    protected array $reglesCreation = [
        'nom'                 => 'requis|longueur_max:150',
        'type'                => 'dans:batiment,route,autre',
        'statut'              => 'dans:planifie,en_cours,suspendu,termine,annule',
        'budget_previsionnel' => 'entier|min:0',
        'client_id'           => 'entier',
        'responsable_id'      => 'entier',
    ];

    private Chantier $chantier;

    public function __construct()
    {
        $this->chantier = new Chantier();
        $this->modele = $this->chantier;
    }

    protected function avantEnregistrement(array $donnees, Request $requete): array
    {
        if (
            ($requete->auth['role'] ?? null) === 'chef_chantier'
            && in_array($donnees['statut'] ?? null, ['termine', 'annule'], true)
        ) {
            Response::erreur('Seul le directeur peut cloturer ou annuler un chantier.', 403);
        }
        return $donnees;
    }

    /** GET /api/v1/chantiers : liste avec noms client/responsable. */
    public function index(Request $requete): void
    {
        $limite   = max(1, min((int) $requete->query('limite', 50), 200));
        $page     = max(1, (int) $requete->query('page', 1));
        $decalage = ($page - 1) * $limite;
        $terme    = (string) $requete->query('recherche', '');

        $resultat = $this->chantier->listeAvecRelations($terme, $limite, $decalage);
        $elements = array_map(
            fn (array $ligne): array => $this->presenter($ligne, $requete),
            $resultat['lignes']
        );

        Response::succes([
            'elements' => $elements,
            'total'    => $resultat['total'],
            'page'     => $page,
            'limite'   => $limite,
        ], 'Liste des chantiers');
    }

    /** GET /api/v1/chantiers/{id} : detail + lots + statistiques d'avancement. */
    public function show(Request $requete): void
    {
        $id = (int) $requete->params['id'];
        $chantier = $this->chantier->trouverAvecRelations($id);
        if ($chantier === null) {
            Response::erreur('Chantier introuvable.', 404);
        }

        $lots = (new Lot())->parChantier($id);

        // Avancement global : moyenne ponderee par le budget des lots (sinon moyenne simple)
        $budgetLots = 0;
        $sommePonderee = 0;
        $sommeAvancement = 0;
        foreach ($lots as $lot) {
            $budget = (int) $lot['budget_previsionnel'];
            $budgetLots += $budget;
            $sommePonderee += (int) $lot['avancement'] * $budget;
            $sommeAvancement += (int) $lot['avancement'];
        }
        $nb = count($lots);
        if ($budgetLots > 0) {
            $avancement = (int) round($sommePonderee / $budgetLots);
        } elseif ($nb > 0) {
            $avancement = (int) round($sommeAvancement / $nb);
        } else {
            $avancement = 0;
        }

        $coutMainOeuvre = (new Pointage())->totalParChantier($id);
        $coutMateriaux  = (new Achat())->totalParChantier($id);
        $budgetPrev     = (int) $chantier['budget_previsionnel'];
        $coutTotal      = $coutMainOeuvre + $coutMateriaux;

        $chantier['lots'] = $lots;
        $chantier['stats'] = [
            'nb_lots'           => $nb,
            'budget_lots'       => $budgetLots,
            'avancement_global' => $avancement,
            'cout_main_oeuvre'  => $coutMainOeuvre,
            'cout_materiaux'    => $coutMateriaux,
            'cout_total'        => $coutTotal,
            'reste_budget'      => $budgetPrev > 0 ? $budgetPrev - $coutTotal : null,
        ];

        $champs = Access::champsReferentiel(
            $requete->auth['role'] ?? null,
            'chantiers'
        );
        if ($champs !== null) {
            $chantier = array_intersect_key($chantier, array_flip($champs));
            if (!in_array('budget_previsionnel', $champs, true)) {
                $chantier['lots'] = array_map(
                    static fn (array $lot): array => array_diff_key($lot, ['budget_previsionnel' => true]),
                    $chantier['lots']
                );
                $chantier['stats'] = array_intersect_key(
                    $chantier['stats'],
                    array_flip(['nb_lots', 'avancement_global'])
                );
            }
        }

        Response::succes($chantier);
    }
}
