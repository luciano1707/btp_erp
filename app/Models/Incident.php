<?php

namespace App\Models;

use App\Core\Database;
use PDO;

final class Incident
{
    /** @param array<string,mixed> $filtre */
    public function liste(array $filtre = []): array
    {
        $pdo = Database::connexion();
        $sql = 'SELECT i.*, c.nom AS chantier_nom, c.code AS chantier_code,
                       TRIM(CONCAT(COALESCE(u.prenom, ""), " ", COALESCE(u.nom, ""))) AS declarant_nom,
                       TRIM(CONCAT(COALESCE(v.prenom, ""), " ", COALESCE(v.nom, ""))) AS suiveur_nom
                FROM incidents i
                LEFT JOIN chantiers c ON c.id = i.chantier_id
                LEFT JOIN utilisateurs u ON u.id = i.declarant_id
                LEFT JOIN utilisateurs v ON v.id = i.suivi_par
                WHERE 1=1';
        $params = [];
        foreach (['chantier_id', 'statut', 'gravite', 'type_incident'] as $champ) {
            if (!empty($filtre[$champ])) {
                $sql .= " AND i.$champ = :$champ";
                $params[$champ] = $filtre[$champ];
            }
        }
        $sql .= ' ORDER BY i.date_incident DESC, i.id DESC';
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function trouverAvecDetails(int $id): ?array
    {
        $pdo = Database::connexion();
        $sql = 'SELECT i.*, c.nom AS chantier_nom, c.code AS chantier_code,
                       TRIM(CONCAT(COALESCE(u.prenom, ""), " ", COALESCE(u.nom, ""))) AS declarant_nom,
                       TRIM(CONCAT(COALESCE(v.prenom, ""), " ", COALESCE(v.nom, ""))) AS suiveur_nom
                FROM incidents i
                LEFT JOIN chantiers c ON c.id = i.chantier_id
                LEFT JOIN utilisateurs u ON u.id = i.declarant_id
                LEFT JOIN utilisateurs v ON v.id = i.suivi_par
                WHERE i.id = :id';
        $stmt = $pdo->prepare($sql);
        $stmt->execute(['id' => $id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return $row === false ? null : $row;
    }

    /** @param array<string,mixed> $donnees */
    public function creer(array $donnees): int
    {
        $pdo = Database::connexion();
        $stmt = $pdo->prepare('INSERT INTO incidents
            (numero, chantier_id, declarant_id, date_incident, lieu, type_incident,
             gravite, victimes, description, premiers_secours, action_corrective, statut, suivi_par)
            VALUES
            (:numero, :chantier_id, :declarant_id, :date_incident, :lieu, :type_incident,
             :gravite, :victimes, :description, :premiers_secours, :action_corrective, :statut, :suivi_par)');
        $stmt->execute([
            'numero'            => $donnees['numero'],
            'chantier_id'       => $donnees['chantier_id'],
            'declarant_id'      => $donnees['declarant_id'],
            'date_incident'     => $donnees['date_incident'],
            'lieu'              => $donnees['lieu'] ?? null,
            'type_incident'     => $donnees['type_incident'] ?? 'incident',
            'gravite'           => $donnees['gravite'] ?? 'faible',
            'victimes'          => $donnees['victimes'] ?? null,
            'description'       => $donnees['description'],
            'premiers_secours'  => $donnees['premiers_secours'] ?? null,
            'action_corrective' => $donnees['action_corrective'] ?? null,
            'statut'            => $donnees['statut'] ?? 'ouvert',
            'suivi_par'         => $donnees['suivi_par'] ?? null,
        ]);
        return (int) $pdo->lastInsertId();
    }

    /** @param array<string,mixed> $donnees */
    public function modifier(int $id, array $donnees): bool
    {
        $autorises = ['lieu', 'type_incident', 'gravite', 'victimes', 'description',
                      'premiers_secours', 'action_corrective', 'statut', 'suivi_par'];
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
            ->prepare('UPDATE incidents SET ' . implode(', ', $champs) . ' WHERE id = :id')
            ->execute($params);
    }

    public static function genererNumero(): string
    {
        return 'INC-' . date('Ymd-His') . '-' . strtoupper(substr(bin2hex(random_bytes(2)), 0, 4));
    }
}
