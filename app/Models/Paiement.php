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
        $sql = "SELECT COALESCE(SUM(montant),0) FROM paiements WHERE statut = 'valide'";
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

    /**
     * Liste tous les paiements avec jointures (pour export)
     * @param array $filtres Filtres optionnels
     * @return array<int,array<string,mixed>>
     */
    public function liste(array $filtres = []): array
    {
        $sql = "SELECT p.*, f.reference AS facture_reference, cl.nom AS client_nom,
                ch.nom AS chantier_nom
                FROM paiements p
                JOIN factures f ON f.id = p.facture_id
                LEFT JOIN clients cl ON cl.id = f.client_id
                LEFT JOIN chantiers ch ON ch.id = f.chantier_id
                WHERE 1=1";
        $params = [];

        if (!empty($filtres['facture_id'])) {
            $sql .= ' AND p.facture_id = :f';
            $params[':f'] = $filtres['facture_id'];
        }
        if (!empty($filtres['chantier_id'])) {
            $sql .= ' AND f.chantier_id = :c';
            $params[':c'] = $filtres['chantier_id'];
        }
        if (!empty($filtres['date_debut'])) {
            $sql .= ' AND p.date_paiement >= :dd';
            $params[':dd'] = $filtres['date_debut'];
        }
        if (!empty($filtres['date_fin'])) {
            $sql .= ' AND p.date_paiement <= :df';
            $params[':df'] = $filtres['date_fin'];
        }

        $sql .= ' ORDER BY p.date_paiement DESC';

        $req = $this->db()->prepare($sql);
        $req->execute($params);
        return $req->fetchAll();
    }
}
