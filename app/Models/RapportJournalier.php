<?php

namespace App\Models;

use App\Core\Database;
use App\Core\Model;
use PDO;

final class RapportJournalier extends Model
{
    protected string $table = 'rapports_journaliers';

    /** Liste des rapports avec le nom du chantier et du chef de chantier. */
    public function liste(): array
    {
        $pdo = Database::connexion();
        $sql = 'SELECT rj.*, c.nom AS chantier_nom,
                       TRIM(CONCAT(COALESCE(u.prenom, ""), " ", COALESCE(u.nom, ""))) AS chef_nom,
                       rj.avancement_pct AS avancement
                FROM rapports_journaliers rj
                LEFT JOIN chantiers c ON c.id = rj.chantier_id
                LEFT JOIN utilisateurs u ON u.id = rj.chef_chantier_id
                ORDER BY rj.date_rapport DESC, rj.cree_le DESC';
        return $pdo->query($sql)->fetchAll(PDO::FETCH_ASSOC);
    }

    /** Detail d'un rapport avec les libelles joints. */
    public function trouverAvecDetails(int $id): ?array
    {
        $pdo = Database::connexion();
        $sql = 'SELECT rj.*, c.nom AS chantier_nom,
                       TRIM(CONCAT(COALESCE(u.prenom, ""), " ", COALESCE(u.nom, ""))) AS chef_nom,
                       rj.avancement_pct AS avancement
                FROM rapports_journaliers rj
                LEFT JOIN chantiers c ON c.id = rj.chantier_id
                LEFT JOIN utilisateurs u ON u.id = rj.chef_chantier_id
                WHERE rj.id = :id';
        $stmt = $pdo->prepare($sql);
        $stmt->execute(['id' => $id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return $row === false ? null : $row;
    }

    public static function genererNumero(): string
    {
        return 'RJ-' . date('Ymd-His') . '-' . strtoupper(substr(bin2hex(random_bytes(2)), 0, 4));
    }
}
