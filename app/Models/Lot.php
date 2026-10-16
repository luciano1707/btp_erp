<?php

namespace App\Models;

use App\Core\Model;

/** Modele des lots (decoupage d'un chantier). */
final class Lot extends Model
{
    protected string $table = 'lots';

    /** Lots d'un chantier, ordonnes. @return array<int,array<string,mixed>> */
    public function parChantier(int $chantierId): array
    {
        $req = $this->db()->prepare(
            'SELECT * FROM lots WHERE chantier_id = :c ORDER BY ordre ASC, id ASC'
        );
        $req->execute([':c' => $chantierId]);
        return $req->fetchAll();
    }
}
