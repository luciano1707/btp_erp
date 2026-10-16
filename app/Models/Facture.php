<?php

namespace App\Models;

use App\Core\DocumentModel;
use PDO;

/** Modele des factures. */
final class Facture extends DocumentModel
{
    protected string $table = 'factures';
    protected string $tableLignes = 'facture_lignes';
    protected string $colonneFk = 'facture_id';

    /** @return array{lignes:array<int,array<string,mixed>>,total:int} */
    public function liste(string $terme, int $limite, int $decalage): array
    {
        $where = '';
        $params = [];
        $terme = trim($terme);
        if ($terme !== '') {
            $where = 'WHERE f.reference LIKE :t0 OR c.nom LIKE :t1';
            $params = [':t0' => "%$terme%", ':t1' => "%$terme%"];
        }
        $jointure = 'LEFT JOIN clients c ON c.id = f.client_id';

        $reqTotal = $this->db()->prepare("SELECT COUNT(*) FROM factures f $jointure $where");
        $reqTotal->execute($params);
        $total = (int) $reqTotal->fetchColumn();

        $req = $this->db()->prepare("SELECT f.*, c.nom AS client_nom FROM factures f $jointure $where
                                     ORDER BY f.id DESC LIMIT :limite OFFSET :decalage");
        foreach ($params as $ph => $v) {
            $req->bindValue($ph, $v);
        }
        $req->bindValue(':limite', $limite, PDO::PARAM_INT);
        $req->bindValue(':decalage', $decalage, PDO::PARAM_INT);
        $req->execute();

        return ['lignes' => $req->fetchAll(), 'total' => $total];
    }

    /** @return array<string,mixed>|null */
    public function trouverAvecLignes(int $id): ?array
    {
        $req = $this->db()->prepare('SELECT f.*, c.nom AS client_nom, ch.nom AS chantier_nom
                                     FROM factures f
                                     LEFT JOIN clients c ON c.id = f.client_id
                                     LEFT JOIN chantiers ch ON ch.id = f.chantier_id
                                     WHERE f.id = :id LIMIT 1');
        $req->execute([':id' => $id]);
        $facture = $req->fetch();
        if (!$facture) {
            return null;
        }
        $facture['lignes'] = $this->lignes($id);
        $facture['paiements'] = (new Paiement())->parFacture($id);
        return $facture;
    }

    /**
     * Recalcule le montant paye et le statut de la facture d'apres ses paiements.
     * Ne modifie pas une facture annulee.
     */
    public function recalculerPaiements(int $id): void
    {
        $facture = $this->trouver($id);
        if ($facture === null || $facture['statut'] === 'annulee') {
            return;
        }

        $reqPaye = $this->db()->prepare('SELECT COALESCE(SUM(montant),0) FROM paiements WHERE facture_id = :id');
        $reqPaye->execute([':id' => $id]);
        $paye = (int) $reqPaye->fetchColumn();
        $ttc = (int) $facture['montant_ttc'];

        // Le statut ne "recule" pas en-deca de "emise" (une facture brouillon le reste tant que non emise)
        $statut = $facture['statut'];
        if ($statut !== 'brouillon') {
            if ($paye <= 0) {
                $statut = 'emise';
            } elseif ($paye >= $ttc) {
                $statut = 'payee';
            } else {
                $statut = 'payee_partiel';
            }
        }

        $this->modifier($id, ['montant_paye' => $paye, 'statut' => $statut]);
    }
}
