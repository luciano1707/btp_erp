<?php

namespace App\Core;

use PDO;

/**
 * Modele de base pour les documents commerciaux a lignes (devis, factures).
 * Gere le calcul HT / TVA / TTC et l'enregistrement transactionnel des lignes.
 * Les enfants definissent $table, $tableLignes et $colonneFk.
 */
abstract class DocumentModel extends Model
{
    /** Table des lignes (ex: devis_lignes). */
    protected string $tableLignes = '';

    /** Colonne de cle etrangere dans la table des lignes (ex: devis_id). */
    protected string $colonneFk = '';

    /**
     * Cree un document et ses lignes dans une transaction, en calculant HT/TVA/TTC.
     *
     * @param array<string,mixed>            $entete   Colonnes de l'en-tete (hors montants calcules)
     * @param array<int,array<string,mixed>> $lignes
     */
    public function creerAvecLignes(array $entete, array $lignes, float $tvaTaux): int
    {
        $db = $this->db();
        $db->beginTransaction();
        try {
            [$ht, $lignesCalculees] = $this->calculerLignes($lignes);
            $tva = (int) round($ht * $tvaTaux / 100);

            $entete['montant_ht']  = $ht;
            $entete['tva_taux']    = $tvaTaux;
            $entete['montant_tva'] = $tva;
            $entete['montant_ttc'] = $ht + $tva;

            $id = $this->insererEntete($entete);
            $this->insererLignes($id, $lignesCalculees);

            $db->commit();
            return $id;
        } catch (\Throwable $e) {
            $db->rollBack();
            throw $e;
        }
    }

    /** @return array{0:int,1:array<int,array<string,mixed>>} [montantHt, lignesCalculees] */
    private function calculerLignes(array $lignes): array
    {
        $ht = 0;
        $sortie = [];
        foreach ($lignes as $ligne) {
            $designation = trim((string) ($ligne['designation'] ?? ''));
            if ($designation === '') {
                continue;
            }
            $quantite = (float) ($ligne['quantite'] ?? 0);
            $prix = (int) ($ligne['prix_unitaire'] ?? 0);
            $montant = (int) round($quantite * $prix);
            $ht += $montant;
            $sortie[] = compact('designation', 'quantite', 'prix') + ['montant' => $montant];
        }
        return [$ht, $sortie];
    }

    private function insererEntete(array $entete): int
    {
        $colonnes = array_keys($entete);
        $marqueurs = array_map(static fn ($c) => ":$c", $colonnes);
        $sql = "INSERT INTO {$this->table} (" . implode(',', $colonnes) . ') VALUES (' . implode(',', $marqueurs) . ')';
        $params = [];
        foreach ($entete as $c => $v) {
            $params[":$c"] = $v;
        }
        $this->db()->prepare($sql)->execute($params);
        return (int) $this->db()->lastInsertId();
    }

    private function insererLignes(int $documentId, array $lignes): void
    {
        $sql = "INSERT INTO {$this->tableLignes} ({$this->colonneFk}, designation, quantite, prix_unitaire, montant)
                VALUES (:doc, :d, :q, :p, :m)";
        $req = $this->db()->prepare($sql);
        foreach ($lignes as $l) {
            $req->execute([
                ':doc' => $documentId, ':d' => $l['designation'],
                ':q' => $l['quantite'], ':p' => $l['prix'], ':m' => $l['montant'],
            ]);
        }
    }

    /** Lignes d'un document. @return array<int,array<string,mixed>> */
    public function lignes(int $documentId): array
    {
        $req = $this->db()->prepare("SELECT * FROM {$this->tableLignes} WHERE {$this->colonneFk} = :id ORDER BY id ASC");
        $req->execute([':id' => $documentId]);
        return $req->fetchAll();
    }
}
