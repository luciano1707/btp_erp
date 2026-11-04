<?php

namespace App\Models;

use App\Core\Database;
use PDO;

final class Validation
{
    /** Créer une nouvelle validation (statut brouillon) */
    public function creer(array $donnees): int
    {
        $pdo = Database::connexion();
        $stmt = $pdo->prepare('INSERT INTO validations 
            (type_operation, operation_id, soumetteur_id, statut, meta)
            VALUES (:type_operation, :operation_id, :soumetteur_id, :statut, :meta)');
        $stmt->execute([
            'type_operation' => $donnees['type_operation'],
            'operation_id' => $donnees['operation_id'],
            'soumetteur_id' => $donnees['soumetteur_id'],
            'statut' => 'brouillon',
            'meta' => isset($donnees['meta']) ? json_encode($donnees['meta']) : null,
        ]);
        return (int) $pdo->lastInsertId();
    }

    /** Soumettre une opération pour validation */
    public function soumettre(int $id): bool
    {
        $pdo = Database::connexion();
        $stmt = $pdo->prepare('UPDATE validations 
            SET statut = :statut, date_soumission = NOW() 
            WHERE id = :id AND statut = :ancien_statut');
        return $stmt->execute([
            'id' => $id,
            'statut' => 'en_attente',
            'ancien_statut' => 'brouillon',
        ]);
    }

    /** Valider une opération */
    public function valider(int $id, int $validateurId): bool
    {
        $pdo = Database::connexion();
        $stmt = $pdo->prepare('UPDATE validations 
            SET statut = :statut, validateur_id = :validateur_id, date_decision = NOW() 
            WHERE id = :id AND statut = :ancien_statut');
        return $stmt->execute([
            'id' => $id,
            'statut' => 'valide',
            'validateur_id' => $validateurId,
            'ancien_statut' => 'en_attente',
        ]);
    }

    /** Refuser une opération */
    public function refuser(int $id, int $validateurId, string $motif): bool
    {
        $pdo = Database::connexion();
        $stmt = $pdo->prepare('UPDATE validations 
            SET statut = :statut, validateur_id = :validateur_id, date_decision = NOW(), motif_refus = :motif 
            WHERE id = :id AND statut = :ancien_statut');
        return $stmt->execute([
            'id' => $id,
            'statut' => 'refuse',
            'validateur_id' => $validateurId,
            'motif' => $motif,
            'ancien_statut' => 'en_attente',
        ]);
    }

    /** Lister les validations en attente pour un validateur */
    public function listeEnAttente(?string $typeOperation = null, ?int $chantierId = null): array
    {
        $pdo = Database::connexion();
        $sql = 'SELECT v.*, 
                u_s.nom AS soumetteur_nom, u_s.prenom AS soumetteur_prenom,
                u_v.nom AS validateur_nom, u_v.prenom AS validateur_prenom
                FROM validations v
                LEFT JOIN utilisateurs u_s ON u_s.id = v.soumetteur_id
                LEFT JOIN utilisateurs u_v ON u_v.id = v.validateur_id
                WHERE v.statut = :statut';
        $params = ['statut' => 'en_attente'];

        if ($typeOperation) {
            $sql .= ' AND v.type_operation = :type_operation';
            $params['type_operation'] = $typeOperation;
        }

        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /** Lister toutes les validations (historique) */
    public function liste(array $filtres = []): array
    {
        $pdo = Database::connexion();
        $sql = 'SELECT v.*, 
                u_s.nom AS soumetteur_nom, u_s.prenom AS soumetteur_prenom,
                u_v.nom AS validateur_nom, u_v.prenom AS validateur_prenom
                FROM validations v
                LEFT JOIN utilisateurs u_s ON u_s.id = v.soumetteur_id
                LEFT JOIN utilisateurs u_v ON u_v.id = v.validateur_id
                WHERE 1=1';
        $params = [];

        if (!empty($filtres['type_operation'])) {
            $sql .= ' AND v.type_operation = :type_operation';
            $params['type_operation'] = $filtres['type_operation'];
        }
        if (!empty($filtres['statut'])) {
            $sql .= ' AND v.statut = :statut';
            $params['statut'] = $filtres['statut'];
        }

        $sql .= ' ORDER BY v.date_soumission DESC, v.id DESC';
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /** Trouver une validation par ID */
    public function trouver(int $id): ?array
    {
        $pdo = Database::connexion();
        $stmt = $pdo->prepare('SELECT * FROM validations WHERE id = :id');
        $stmt->execute(['id' => $id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return $row === false ? null : $row;
    }

    /** Compter les validations par statut */
    public function compterParStatut(): array
    {
        $pdo = Database::connexion();
        $stmt = $pdo->prepare('SELECT statut, COUNT(*) as nombre FROM validations GROUP BY statut');
        $stmt->execute();
        $result = [];
        foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
            $result[$row['statut']] = (int) $row['nombre'];
        }
        return $result;
    }

    /** Vérifier si l'utilisateur peut valider (pas auto-validation) */
    public function peutValider(int $id, int $validateurId): bool
    {
        $validation = $this->trouver($id);
        if (!$validation) {
            return false;
        }
        // Empêcher l'auto-validation
        if ((int) $validation['soumetteur_id'] === $validateurId) {
            return false;
        }
        // Vérifier que le statut est en_attente
        return $validation['statut'] === 'en_attente';
    }
}
