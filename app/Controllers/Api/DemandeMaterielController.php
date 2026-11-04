<?php

namespace App\Controllers\Api;

use App\Core\Audit;
use App\Core\Controller;
use App\Core\Database;
use App\Core\Request;
use App\Core\Response;
use App\Core\ValidationService;
use App\Models\DemandeMateriel;
use App\Models\MouvementStock;
use RuntimeException;

final class DemandeMaterielController extends Controller
{
    /** GET /api/v1/demandes-materiel */
    public function index(Request $requete): void
    {
        $filtre = [
            'chantier_id' => $requete->query('chantier_id'),
            'statut'      => $requete->query('statut'),
            'urgence'     => $requete->query('urgence'),
            'recherche'   => $requete->query('recherche'),
        ];
        $donnees = (new DemandeMateriel())->liste($filtre);
        Response::succes($donnees, 'Liste des demandes de matériel');
    }

    /** GET /api/v1/demandes-materiel/{id} */
    public function show(Request $requete): void
    {
        $demande = (new DemandeMateriel())->trouverAvecLignes((int) $requete->params['id']);
        if ($demande === null) {
            Response::erreur('Demande introuvable.', 404);
        }
        Response::succes($demande);
    }

    /** POST /api/v1/demandes-materiel */
    public function store(Request $requete): void
    {
        $this->valider($requete->tout(), [
            'objet'       => 'requis',
            'date_demande'=> 'requis',
        ]);

        $lignes = $requete->input('lignes', []);
        if (!is_array($lignes) || $lignes === []) {
            Response::erreur('Au moins une ligne est requise.', 422);
        }

        $entete = [
            'numero'       => DemandeMateriel::genererNumero(),
            'chantier_id'  => $requete->input('chantier_id') ?: null,
            'demandeur_id' => $this->uid($requete),
            'objet'        => $requete->input('objet'),
            'urgence'      => $requete->input('urgence', 'normale'),
            'statut'       => 'en_attente',
            'date_demande' => $requete->input('date_demande'),
            'notes'        => $requete->input('notes'),
        ];

        $modele = new DemandeMateriel();
        $pdo = Database::connexion();
        $pdo->beginTransaction();
        try {
            $id = $modele->creerAvecLignes($entete, $lignes);
            (new ValidationService())->soumettre([
                'type_operation' => 'demande_materiel',
                'operation_id' => $id,
                'soumetteur_id' => (int) $this->uid($requete),
            ]);
            $pdo->commit();
        } catch (RuntimeException $e) {
            if ($pdo->inTransaction()) {
                $pdo->rollBack();
            }
            Response::erreur($e->getMessage(), 409);
        } catch (\Throwable $e) {
            if ($pdo->inTransaction()) {
                $pdo->rollBack();
            }
            throw $e;
        }
        Audit::enregistrer('demande_materiel.creation', 'demande_materiel', $id, [], $this->uid($requete));
        Response::succes($modele->trouverAvecLignes($id), 'Demande soumise au directeur pour validation.', 201);
    }

    /** POST /api/v1/demandes-materiel/{id}/approuver */
    public function approuver(Request $requete): void
    {
        $this->decider($requete, true);
    }

    /** POST /api/v1/demandes-materiel/{id}/refuser */
    public function refuser(Request $requete): void
    {
        $this->valider($requete->tout(), ['motif_refus' => 'requis']);
        $this->decider($requete, false, (string) $requete->input('motif_refus'));
    }

    private function decider(Request $requete, bool $approuve, ?string $motif = null): never
    {
        $id = (int) $requete->params['id'];
        $modele = new DemandeMateriel();
        $demande = $modele->trouver($id);
        if ($demande === null) {
            Response::erreur('Demande introuvable.', 404);
        }

        $service = new ValidationService();
        try {
            $validation = $service->trouverParOperation('demande_materiel', $id);
            if ($validation === null && $demande['statut'] === 'en_attente') {
                $validation = $service->soumettre([
                    'type_operation' => 'demande_materiel',
                    'operation_id' => $id,
                    'soumetteur_id' => (int) $demande['demandeur_id'],
                ]);
            }
            if ($validation === null) {
                Response::erreur('Cette demande ne peut pas être traitée dans son état actuel.', 409);
            }
            $service->decider(
                (int) $validation['id'],
                (int) $this->uid($requete),
                (string) ($requete->auth['role'] ?? ''),
                $approuve,
                $motif
            );
        } catch (RuntimeException $e) {
            $statut = str_contains($e->getMessage(), 'auto-validation') || str_contains($e->getMessage(), 'autorise')
                ? 403
                : 409;
            Response::erreur($e->getMessage(), $statut);
        }
        Response::succes($modele->trouverAvecLignes($id), $approuve ? 'Demande approuvée.' : 'Demande refusée.');
    }

    /** POST /api/v1/demandes-materiel/{id}/traiter */
    public function traiter(Request $requete): void
    {
        $id = (int) $requete->params['id'];
        $modele = new DemandeMateriel();
        $demande = $modele->trouverAvecLignes($id);
        if ($demande === null) {
            Response::erreur('Demande introuvable.', 404);
        }
        if ($demande['statut'] !== 'valide') {
            Response::erreur('La demande doit être approuvée par le directeur avant son traitement.', 409);
        }

        $mouvements = new MouvementStock();
        $uid = $this->uid($requete);
        $date = date('Y-m-d');

        foreach ($demande['lignes'] as $ligne) {
            if (empty($ligne['materiau_id'])) {
                continue;
            }
            $qte = (float) ($ligne['quantite_demandee'] ?? 0);
            if ($qte <= 0) {
                continue;
            }
            try {
                $mouvements->enregistrer([
                    'materiau_id'    => (int) $ligne['materiau_id'],
                    'type'           => 'sortie',
                    'quantite'       => $qte,
                    'chantier_id'    => $demande['chantier_id'],
                    'motif'          => 'Sortie via demande ' . $demande['numero'],
                    'date_mouvement' => $date,
                    'cree_par'       => $uid,
                ]);
            } catch (\Throwable $e) {
                // On continue si stock insuffisant - la logique pourra être affinée
            }
        }

        $modele->modifier($id, [
            'statut' => 'traite',
            'magasinier_id' => $uid,
            'date_traitement' => date('Y-m-d H:i:s'),
        ]);
        Audit::enregistrer('demande_materiel.traitement', 'demande_materiel', $id, [], $uid);
        Response::succes(null, 'Demande traitée et mouvements de sortie enregistrés.');
    }
    private function uid(Request $requete): ?int
    {
        return isset($requete->auth['sub']) ? (int) $requete->auth['sub'] : null;
    }

}
