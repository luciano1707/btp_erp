<?php

namespace App\Models;

use App\Core\Model;

/** Modele des pointages (main d'oeuvre). */
final class Pointage extends Model
{
    protected string $table = 'pointages';

    /** Coefficient de cout selon le type de presence. */
    public const COEFFICIENTS = ['journee' => 1.0, 'demi_journee' => 0.5, 'absent' => 0.0];

    /**
     * Feuille de pointage d'un chantier (optionnellement filtree par date), avec nom employe.
     * @return array<int,array<string,mixed>>
     */
    public function feuille(int $chantierId, ?string $date = null): array
    {
        $sql = "SELECT p.*, e.nom AS employe_nom, e.prenom AS employe_prenom
                FROM pointages p
                JOIN employes e ON e.id = p.employe_id
                WHERE p.chantier_id = :c";
        $params = [':c' => $chantierId];

        if ($date !== null && $date !== '') {
            $sql .= ' AND p.date_pointage = :d';
            $params[':d'] = $date;
        }
        $sql .= ' ORDER BY p.date_pointage DESC, e.nom ASC';

        $req = $this->db()->prepare($sql);
        $req->execute($params);
        return $req->fetchAll();
    }

    /**
     * Enregistre (ou met a jour) une ligne de pointage pour un employe et une date.
     * Le couple (employe, date) est unique : on remplace la valeur existante.
     */
    public function enregistrerLigne(
        int $chantierId,
        ?int $lotId,
        int $employeId,
        string $date,
        string $type,
        int $cout,
        ?int $auteurId
    ): void {
        $sql = 'INSERT INTO pointages (chantier_id, lot_id, employe_id, date_pointage, type_presence, cout, cree_par)
                VALUES (:c, :lot, :e, :d, :t, :cout, :auteur)
                ON DUPLICATE KEY UPDATE
                    chantier_id = VALUES(chantier_id),
                    lot_id      = VALUES(lot_id),
                    type_presence = VALUES(type_presence),
                    cout        = VALUES(cout)';

        $this->db()->prepare($sql)->execute([
            ':c'      => $chantierId,
            ':lot'    => $lotId,
            ':e'      => $employeId,
            ':d'      => $date,
            ':t'      => $type,
            ':cout'   => $cout,
            ':auteur' => $auteurId,
        ]);
    }

    /** Cout total de main d'oeuvre d'un chantier (en Ariary). */
    public function totalParChantier(int $chantierId): int
    {
        $req = $this->db()->prepare('SELECT COALESCE(SUM(cout),0) FROM pointages WHERE chantier_id = :c');
        $req->execute([':c' => $chantierId]);
        return (int) $req->fetchColumn();
    }
}
