<?php

namespace App\Models;

use App\Core\Model;

/** Modele des paiements de factures. */
final class Paiement extends Model
{
    protected string $table = 'paiements';

    /** Paiements d'une facture. @return array<int,array<string,mixed>> */
    public function parFacture(int $factureId): array
    {
        $req = $this->db()->prepare('SELECT * FROM paiements WHERE facture_id = :id ORDER BY id ASC');
        $req->execute([':id' => $factureId]);
        return $req->fetchAll();
    }

    /** Total encaisse sur une periode (pour la tresorerie). */
    public function totalEncaisse(?string $debut = null, ?string $fin = null): int
    {
        $sql = 'SELECT COALESCE(SUM(montant),0) FROM paiements WHERE 1=1';
        $params = [];
        if ($debut !== null) {
            $sql .= ' AND date_paiement >= :debut';
            $params[':debut'] = $debut;
        }
        if ($fin !== null) {
            $sql .= ' AND date_paiement <= :fin';
            $params[':fin'] = $fin;
        }
        $req = $this->db()->prepare($sql);
        $req->execute($params);
        return (int) $req->fetchColumn();
    }
}
