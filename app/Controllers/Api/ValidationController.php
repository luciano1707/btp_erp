<?php

namespace App\Controllers\Api;

use App\Core\Audit;
use App\Core\Controller;
use App\Core\Request;
use App\Core\Response;
use App\Core\ValidationService;
use RuntimeException;

final class ValidationController extends Controller
{
    private ValidationService $service;

    public function __construct()
    {
        $this->service = new ValidationService();
    }

    /** GET /api/v1/validations - Liste des demandes visibles */
    public function index(Request $requete): void
    {
        $role = $requete->auth['role'] ?? null;
        $uid = $this->uid($requete);
        $limite = max(1, min((int) $requete->query('limite', 300), 1000));
        $page = max(1, (int) $requete->query('page', 1));

        $filtres = [
            'type_operation' => $requete->query('type_operation'),
            'statut' => $requete->query('statut'),
            'module' => $requete->query('module'),
            'chantier_id' => $requete->query('chantier_id'),
            'operation_id' => $requete->query('operation_id'),
            'recherche' => $requete->query('recherche'),
        ];
        $res = $this->service->lister($filtres, $role, $uid, $limite, ($page - 1) * $limite);

        Response::succes($res['elements'], 'Liste des validations');
    }

    /** GET /api/v1/validations/en-attente */
    public function enAttente(Request $requete): void
    {
        $role = $requete->auth['role'] ?? null;
        $res = $this->service->lister(
            ['statut' => 'en_attente', 'type_operation' => $requete->query('type_operation')],
            $role,
            $this->uid($requete),
            500
        );
        Response::succes($res['elements'], 'Validations en attente');
    }

    /** GET /api/v1/validations/indicateurs */
    public function indicateurs(Request $requete): void
    {
        Response::succes(
            $this->service->indicateurs($requete->auth['role'] ?? null),
            'Indicateurs de validation'
        );
    }

    /** GET /api/v1/validations/{id} */
    public function show(Request $requete): void
    {
        $id = (int) ($requete->params['id'] ?? 0);
        $validation = $this->service->details($id);
        if ($validation === null) {
            Response::erreur('Validation introuvable', 404);
        }
        if (!$this->peutVoir($validation, $requete)) {
            Response::erreur('Acces refuse a cette validation.', 403);
        }
        Response::succes($validation, 'Detail de la validation');
    }

    /**
     * POST /api/v1/validations
     * Cree et soumet directement une demande pour une operation.
     */
    public function store(Request $requete): void
    {
        $this->valider($requete->tout(), [
            'type_operation' => 'requis',
            'operation_id' => 'requis|entier',
        ]);

        $uid = $this->uid($requete);
        try {
            $validation = $this->service->soumettre([
                'type_operation' => (string) $requete->input('type_operation'),
                'operation_id' => (int) $requete->input('operation_id'),
                'soumetteur_id' => $uid,
                'montant' => $requete->input('montant'),
                'chantier_id' => $requete->input('chantier_id'),
                'meta' => $requete->input('meta', []),
            ]);
        } catch (RuntimeException $e) {
            $this->erreurMetier($e);
        }

        Response::succes($validation, 'Demande de validation soumise', 201);
    }

    /**
     * POST /api/v1/validations/soumettre
     * Soumet une operation identifiee par son type et son id.
     */
    public function soumettreOperation(Request $requete): void
    {
        $this->valider($requete->tout(), [
            'type_operation' => 'requis',
            'operation_id' => 'requis|entier',
        ]);

        try {
            $validation = $this->service->soumettre([
                'type_operation' => (string) $requete->input('type_operation'),
                'operation_id' => (int) $requete->input('operation_id'),
                'soumetteur_id' => $this->uid($requete),
                'montant' => $requete->input('montant'),
                'chantier_id' => $requete->input('chantier_id'),
                'meta' => $requete->input('meta', []),
            ]);
        } catch (RuntimeException $e) {
            $this->erreurMetier($e);
        }

        Response::succes($validation, 'Demande de validation soumise');
    }

    /** POST /api/v1/validations/{id}/soumettre - Re-soumission d'une demande existante */
    public function soumettre(Request $requete): void
    {
        $id = (int) ($requete->params['id'] ?? 0);
        $validation = $this->service->trouver($id);
        if ($validation === null) {
            Response::erreur('Validation introuvable', 404);
        }
        if (!$this->peutVoir($validation, $requete)) {
            Response::erreur('Acces refuse a cette validation.', 403);
        }

        try {
            $resultat = $this->service->soumettre([
                'type_operation' => (string) $validation['type_operation'],
                'operation_id' => (int) $validation['operation_id'],
                'soumetteur_id' => $this->uid($requete),
                'meta' => json_decode((string) ($validation['meta'] ?? '{}'), true) ?: [],
            ]);
        } catch (RuntimeException $e) {
            $this->erreurMetier($e);
        }

        Response::succes($resultat, 'Validation soumise');
    }

    /** POST /api/v1/validations/{id}/valider */
    public function approuver(Request $requete): void
    {
        $this->decider($requete, true);
    }

    /** POST /api/v1/validations/{id}/refuser */
    public function refuser(Request $requete): void
    {
        $this->decider($requete, false);
    }

    private function decider(Request $requete, bool $approuve): never
    {
        $id = (int) ($requete->params['id'] ?? 0);
        $uid = $this->uid($requete);
        $role = (string) ($requete->auth['role'] ?? '');
        $motif = $requete->input('motif', $requete->input('motif_refus'));

        try {
            $validation = $this->service->decider($id, $uid, $role, $approuve, is_string($motif) ? $motif : null);
        } catch (RuntimeException $e) {
            $this->erreurMetier($e);
        }

        Response::succes($validation, $approuve ? 'Operation validee' : 'Operation refusee');
    }

    private function peutVoir(array $validation, Request $requete): bool
    {
        $role = $requete->auth['role'] ?? null;
        if ($role === 'directeur') {
            return true;
        }
        if ((int) ($validation['soumetteur_id'] ?? 0) === $this->uid($requete)) {
            return true;
        }
        return in_array((string) $validation['type_operation'], ValidationService::typesAutorises($role), true);
    }

    private function erreurMetier(RuntimeException $e): never
    {
        $message = $e->getMessage();
        $statut = 409;
        if (str_contains($message, 'auto-validation') || str_contains($message, 'autorise')) {
            $statut = 403;
        } elseif (str_contains($message, 'obligatoire') || str_contains($message, 'invalide')) {
            $statut = 422;
        }
        Response::erreur($message, $statut);
    }

    private function uid(Request $requete): ?int
    {
        return isset($requete->auth['sub']) ? (int) $requete->auth['sub'] : null;
    }
}
