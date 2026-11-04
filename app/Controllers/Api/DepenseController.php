<?php

namespace App\Controllers\Api;

use App\Core\Audit;
use App\Core\Controller;
use App\Core\Request;
use App\Core\Response;
use App\Core\ValidationService;
use App\Models\Depense;
use RuntimeException;

final class DepenseController extends Controller
{
    /** GET /api/v1/depenses */
    public function index(Request $requete): void
    {
        $filtre = [
            'chantier_id' => $requete->query('chantier_id'),
            'statut'      => $requete->query('statut'),
            'categorie'   => $requete->query('categorie'),
            'date_debut'  => $requete->query('date_debut'),
            'date_fin'    => $requete->query('date_fin'),
        ];
        Response::succes((new Depense())->liste($filtre), 'Liste des depenses');
    }

    /** GET /api/v1/depenses/{id} */
    public function show(Request $requete): void
    {
        $depense = (new Depense())->trouverAvecDetails((int) $requete->params['id']);
        if ($depense === null) {
            Response::erreur('Depense introuvable.', 404);
        }
        Response::succes($depense);
    }

    /** POST /api/v1/depenses */
    public function store(Request $requete): void
    {
        $this->valider($requete->tout(), [
            'categorie'    => 'requis|longueur_max:80',
            'libelle'      => 'requis|longueur_max:150',
            'montant'      => 'requis|numerique|min:0',
            'date_depense' => 'requis',
        ]);

        $statut = $requete->input('statut', 'en_attente');
        if (!in_array($statut, ['brouillon', 'en_attente'], true)) {
            $statut = 'en_attente';
        }

        $id = (new Depense())->creer([
            'numero'        => Depense::genererNumero(),
            'chantier_id'   => $requete->input('chantier_id') ?: null,
            'declarant_id'  => $this->uid($requete),
            'categorie'     => $requete->input('categorie'),
            'libelle'       => $requete->input('libelle'),
            'montant'       => $requete->input('montant'),
            'devise'        => $requete->input('devise', 'MGA'),
            'date_depense'  => $requete->input('date_depense'),
            'mode_paiement' => $requete->input('mode_paiement'),
            'beneficiaire'  => $requete->input('beneficiaire'),
            'justificatif'  => $requete->input('justificatif'),
            'statut'        => $statut,
            'notes'         => $requete->input('notes'),
        ]);

        Audit::enregistrer('depense.creation', 'depense', $id, [], $this->uid($requete));

        if ($statut === 'en_attente') {
            try {
                (new ValidationService())->soumettre([
                    'type_operation' => 'depense',
                    'operation_id' => $id,
                    'soumetteur_id' => $this->uid($requete),
                ]);
            } catch (RuntimeException $e) {
                Response::erreur($e->getMessage(), 409);
            }
        }

        Response::succes((new Depense())->trouverAvecDetails($id), 'Depense creee.', 201);
    }

    /** POST /api/v1/depenses/{id}/valider */
    public function traiterValidation(Request $requete): void
    {
        $this->decider($requete, true);
    }

    /** POST /api/v1/depenses/{id}/rejeter */
    public function rejeter(Request $requete): void
    {
        $this->valider($requete->tout(), ['motif_rejet' => 'requis']);
        $this->decider($requete, false, (string) $requete->input('motif_rejet'));
    }

    private function decider(Request $requete, bool $approuve, ?string $motif = null): never
    {
        $id = (int) $requete->params['id'];
        $modele = new Depense();
        $depense = $modele->trouverAvecDetails($id);
        if ($depense === null) {
            Response::erreur('Depense introuvable.', 404);
        }

        $uid = $this->uid($requete);
        $service = new ValidationService();

        try {
            $validation = $service->trouverParOperation('depense', $id);
            if ($validation === null) {
                if (!in_array($depense['statut'], ['brouillon', 'en_attente'], true)) {
                    Response::erreur('Cette depense ne peut pas etre traitee dans son etat actuel.', 409);
                }
                $validation = $service->soumettre([
                    'type_operation' => 'depense',
                    'operation_id' => $id,
                    'soumetteur_id' => (int) $depense['declarant_id'],
                ]);
            }
            $service->decider(
                (int) $validation['id'],
                (int) $uid,
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

        Response::succes(
            $modele->trouverAvecDetails($id),
            $approuve ? 'Depense validee.' : 'Depense rejetee.'
        );
    }

    /** POST /api/v1/depenses/{id}/soumettre */
    public function soumettre(Request $requete): void
    {
        $id = (int) $requete->params['id'];
        $depense = (new Depense())->trouverAvecDetails($id);
        if ($depense === null) {
            Response::erreur('Depense introuvable.', 404);
        }
        if (!in_array($depense['statut'], ['brouillon', 'rejete'], true)) {
            Response::erreur('Cette depense ne peut pas etre soumise dans son etat actuel.', 409);
        }

        try {
            $validation = (new ValidationService())->soumettre([
                'type_operation' => 'depense',
                'operation_id' => $id,
                'soumetteur_id' => $this->uid($requete),
            ]);
        } catch (RuntimeException $e) {
            Response::erreur($e->getMessage(), 409);
        }

        Response::succes($validation, 'Depense soumise a validation.');
    }

    private function uid(Request $requete): ?int
    {
        return isset($requete->auth['sub']) ? (int) $requete->auth['sub'] : null;
    }
}
