<?php

namespace App\Models;

use App\Core\Model;
use PDO;

/** Modele des achats (en-tete + lignes). */
final class Achat extends Model
{
    protected string $table = 'achats';

    /**
     * Liste paginee des achats avec nom fournisseur / chantier.
     * @return array{lignes:array<int,array<string,mixed>>,total:int}
     */
    public function liste(string $terme, int $limite, int $decalage): array
    {
        $where = '';
        $params = [];
        $terme = trim($terme);
        if ($terme !== '') {
            $where = 'WHERE a.reference LIKE :t0 OR f.nom LIKE :t1 OR c.nom LIKE :t2';
            $params = [':t0' => "%$terme%", ':t1' => "%$terme%", ':t2' => "%$terme%"];
        }

        $jointures = 'LEFT JOIN fournisseurs f ON f.id = a.fournisseur_id
                      LEFT JOIN chantiers c ON c.id = a.chantier_id';

        $reqTotal = $this->db()->prepare("SELECT COUNT(*) FROM achats a $jointures $where");
        $reqTotal->execute($params);
        $total = (int) $reqTotal->fetchColumn();

        $sql = "SELECT a.*, f.nom AS fournisseur_nom, c.nom AS chantier_nom
                FROM achats a $jointures $where
                ORDER BY a.id DESC LIMIT :limite OFFSET :decalage";
        $req = $this->db()->prepare($sql);
        foreach ($params as $ph => $v) {
            $req->bindValue($ph, $v);
        }
        $req->bindValue(':limite', $limite, PDO::PARAM_INT);
        $req->bindValue(':decalage', $decalage, PDO::PARAM_INT);
        $req->execute();

        return ['lignes' => $req->fetchAll(), 'total' => $total];
    }

    /** Achat complet (en-tete + noms + lignes). @return array<string,mixed>|null */
    public function trouverAvecLignes(int $id): ?array
    {
        $sql = "SELECT a.*, f.nom AS fournisseur_nom, c.nom AS chantier_nom,
                   CONCAT_WS(' ', NULLIF(TRIM(u.prenom), ''), u.nom) AS cree_par_nom
                FROM achats a
                LEFT JOIN fournisseurs f ON f.id = a.fournisseur_id
                LEFT JOIN chantiers c ON c.id = a.chantier_id
                LEFT JOIN utilisateurs u ON u.id = a.cree_par
                WHERE a.id = :id LIMIT 1";
        $req = $this->db()->prepare($sql);
        $req->execute([':id' => $id]);
        $achat = $req->fetch();
        if (!$achat) {
            return null;
        }

        $reqL = $this->db()->prepare('SELECT * FROM achat_lignes WHERE achat_id = :id ORDER BY id ASC');
        $reqL->execute([':id' => $id]);
        $achat['lignes'] = $reqL->fetchAll();

        return $achat;
    }

    /**
     * Cree un achat et ses lignes dans une transaction. Calcule les montants.
     *
     * @param array<string,mixed>            $entete
     * @param array<int,array<string,mixed>> $lignes
     */
    public function creerAvecLignes(array $entete, array $lignes): int
    {
        $db = $this->db();
        $db->beginTransaction();
        try {
            $total = 0;
            $lignesCalculees = [];
            foreach ($lignes as $ligne) {
                $designation = trim((string) ($ligne['designation'] ?? ''));
                if ($designation === '') {
                    continue;
                }
                $quantite = (float) ($ligne['quantite'] ?? 0);
                $prix = (int) ($ligne['prix_unitaire'] ?? 0);
                $montant = (int) round($quantite * $prix);
                $total += $montant;
                $lignesCalculees[] = [
                    'materiau_id'   => !empty($ligne['materiau_id']) ? (int) $ligne['materiau_id'] : null,
                    'designation'   => $designation,
                    'quantite'      => $quantite,
                    'prix_unitaire' => $prix,
                    'montant'       => $montant,
                ];
            }

            $entete['montant_total'] = $total;
            $colonnes = array_keys($entete);
            $marqueurs = array_map(static fn ($c) => ":$c", $colonnes);
            $sql = 'INSERT INTO achats (' . implode(',', $colonnes) . ') VALUES (' . implode(',', $marqueurs) . ')';
            $params = [];
            foreach ($entete as $c => $v) {
                $params[":$c"] = $v;
            }
            $db->prepare($sql)->execute($params);
            $achatId = (int) $db->lastInsertId();

            $reqLigne = $db->prepare(
                'INSERT INTO achat_lignes (achat_id, materiau_id, designation, quantite, prix_unitaire, montant)
                 VALUES (:a, :m, :d, :q, :p, :mt)'
            );
            foreach ($lignesCalculees as $l) {
                $reqLigne->execute([
                    ':a' => $achatId, ':m' => $l['materiau_id'], ':d' => $l['designation'],
                    ':q' => $l['quantite'], ':p' => $l['prix_unitaire'], ':mt' => $l['montant'],
                ]);
            }

            $db->commit();
            return $achatId;
        } catch (\Throwable $e) {
            $db->rollBack();
            throw $e;
        }
    }

    /** Total des achats (materiaux) impute a un chantier, hors achats annules. */
    public function totalParChantier(int $chantierId): int
    {
        $req = $this->db()->prepare(
            "SELECT COALESCE(SUM(montant_total),0) FROM achats WHERE chantier_id = :c AND statut <> 'annule'"
        );
        $req->execute([':c' => $chantierId]);
        return (int) $req->fetchColumn();
    }
}
