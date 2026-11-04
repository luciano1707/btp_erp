<?php

namespace App\Models;

use App\Core\Database;
use PDO;

final class Securite
{
    /** @param array<string,mixed> $filtre */
    public function liste(array $filtre = []): array
    {
        $pdo = Database::connexion();
        $sql = 'SELECT s.*, c.nom AS chantier_nom, c.code AS chantier_code,
                       TRIM(CONCAT(COALESCE(u.prenom, ""), " ", COALESCE(u.nom, ""))) AS declarant_nom
                FROM securite_observations s
                LEFT JOIN chantiers c ON c.id = s.chantier_id
                LEFT JOIN utilisateurs u ON u.id = s.declarant_id
                WHERE 1=1';
        $params = [];
        foreach (['chantier_id', 'statut', 'type_observation'] as $champ) {
            if (!empty($filtre[$champ])) {
                $sql .= " AND s.$champ = :$champ";
                $params[$champ] = $filtre[$champ];
            }
        }
        $sql .= ' ORDER BY s.date_observation DESC, s.id DESC';
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function trouverAvecDetails(int $id): ?array
    {
        $pdo = Database::connexion();
        $sql = 'SELECT s.*, c.nom AS chantier_nom, c.code AS chantier_code,
                       TRIM(CONCAT(COALESCE(u.prenom, ""), " ", COALESCE(u.nom, ""))) AS declarant_nom
                FROM securite_observations s
                LEFT JOIN chantiers c ON c.id = s.chantier_id
                LEFT JOIN utilisateurs u ON u.id = s.declarant_id
                WHERE s.id = :id';
        $stmt = $pdo->prepare($sql);
        $stmt->execute(['id' => $id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return $row === false ? null : $row;
    }

    /** @param array<string,mixed> $donnees */
    public function creer(array $donnees): int
    {
        $pdo = Database::connexion();
        $stmt = $pdo->prepare('INSERT INTO securite_observations
            (numero, chantier_id, declarant_id, date_observation, lieu, type_observation,
             description, action_immediate, mesure_preventive, statut)
            VALUES
            (:numero, :chantier_id, :declarant_id, :date_observation, :lieu, :type_observation,
             :description, :action_immediate, :mesure_preventive, :statut)');
        $stmt->execute([
            'numero'            => $donnees['numero'],
            'chantier_id'       => $donnees['chantier_id'],
            'declarant_id'      => $donnees['declarant_id'],
            'date_observation'  => $donnees['date_observation'],
            'lieu'              => $donnees['lieu'] ?? null,
            'type_observation'  => $donnees['type_observation'] ?? 'danger',
            'description'       => $donnees['description'],
            'action_immediate'  => $donnees['action_immediate'] ?? null,
            'mesure_preventive' => $donnees['mesure_preventive'] ?? null,
            'statut'            => $donnees['statut'] ?? 'ouvert',
        ]);
        return (int) $pdo->lastInsertId();
    }

    /** @param array<string,mixed> $donnees */
    public function modifier(int $id, array $donnees): bool
    {
        $autorises = ['lieu', 'type_observation', 'description', 'action_immediate', 'mesure_preventive', 'statut'];
        $champs = [];
        $params = ['id' => $id];
        foreach ($autorises as $champ) {
            if (array_key_exists($champ, $donnees)) {
                $champs[] = "$champ = :$champ";
                $params[$champ] = $donnees[$champ];
            }
        }
        if ($champs === []) {
            return false;
        }
        return Database::connexion()
            ->prepare('UPDATE securite_observations SET ' . implode(', ', $champs) . ' WHERE id = :id')
            ->execute($params);
    }

    public static function genererNumero(): string
    {
        return 'SO-' . date('Ymd-His') . '-' . strtoupper(substr(bin2hex(random_bytes(2)), 0, 4));
    }
}
