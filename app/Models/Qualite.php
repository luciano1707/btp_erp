<?php

namespace App\Models;

use App\Core\Database;
use PDO;

final class Qualite
{
    /** @param array<string,mixed> $filtre */
    public function liste(array $filtre = []): array
    {
        $pdo = Database::connexion();
        $sql = 'SELECT q.*, c.nom AS chantier_nom, c.code AS chantier_code,
                       l.nom AS lot_nom,
                       TRIM(CONCAT(COALESCE(u.prenom, ""), " ", COALESCE(u.nom, ""))) AS inspecteur_nom
                FROM qualite_inspections q
                LEFT JOIN chantiers c ON c.id = q.chantier_id
                LEFT JOIN lots l ON l.id = q.lot_id
                LEFT JOIN utilisateurs u ON u.id = q.inspecteur_id
                WHERE 1=1';
        $params = [];
        foreach (['chantier_id', 'statut', 'resultat'] as $champ) {
            if (!empty($filtre[$champ])) {
                $sql .= " AND q.$champ = :$champ";
                $params[$champ] = $filtre[$champ];
            }
        }
        $sql .= ' ORDER BY q.date_inspection DESC, q.id DESC';
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function trouverAvecDetails(int $id): ?array
    {
        $pdo = Database::connexion();
        $sql = 'SELECT q.*, c.nom AS chantier_nom, c.code AS chantier_code,
                       l.nom AS lot_nom,
                       TRIM(CONCAT(COALESCE(u.prenom, ""), " ", COALESCE(u.nom, ""))) AS inspecteur_nom
                FROM qualite_inspections q
                LEFT JOIN chantiers c ON c.id = q.chantier_id
                LEFT JOIN lots l ON l.id = q.lot_id
                LEFT JOIN utilisateurs u ON u.id = q.inspecteur_id
                WHERE q.id = :id';
        $stmt = $pdo->prepare($sql);
        $stmt->execute(['id' => $id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return $row === false ? null : $row;
    }

    /** @param array<string,mixed> $donnees */
    public function creer(array $donnees): int
    {
        $pdo = Database::connexion();
        $stmt = $pdo->prepare('INSERT INTO qualite_inspections
            (numero, chantier_id, inspecteur_id, lot_id, date_inspection, type_inspection,
             resultat, constat, action_corrective, statut)
            VALUES
            (:numero, :chantier_id, :inspecteur_id, :lot_id, :date_inspection, :type_inspection,
             :resultat, :constat, :action_corrective, :statut)');
        $stmt->execute([
            'numero'           => $donnees['numero'],
            'chantier_id'      => $donnees['chantier_id'],
            'inspecteur_id'    => $donnees['inspecteur_id'],
            'lot_id'           => $donnees['lot_id'] ?? null,
            'date_inspection'  => $donnees['date_inspection'],
            'type_inspection'  => $donnees['type_inspection'] ?? null,
            'resultat'         => $donnees['resultat'] ?? 'conforme',
            'constat'          => $donnees['constat'] ?? null,
            'action_corrective'=> $donnees['action_corrective'] ?? null,
            'statut'           => $donnees['statut'] ?? 'ouvert',
        ]);
        return (int) $pdo->lastInsertId();
    }

    /** @param array<string,mixed> $donnees */
    public function modifier(int $id, array $donnees): bool
    {
        $autorises = ['lot_id', 'type_inspection', 'resultat', 'constat', 'action_corrective', 'statut'];
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
            ->prepare('UPDATE qualite_inspections SET ' . implode(', ', $champs) . ' WHERE id = :id')
            ->execute($params);
    }

    public static function genererNumero(): string
    {
        return 'QI-' . date('Ymd-His') . '-' . strtoupper(substr(bin2hex(random_bytes(2)), 0, 4));
    }
}
