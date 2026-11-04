<?php

namespace App\Models;

use App\Core\Database;
use PDO;

final class DemandeMateriel
{
    public function liste(array $filtre = []): array
    {
        $pdo = Database::connexion();
        $sql = 'SELECT dm.*, u.nom AS demandeur_nom, u.prenom AS demandeur_prenom, c.nom AS chantier_nom
                FROM demandes_materiel dm
                LEFT JOIN utilisateurs u ON u.id = dm.demandeur_id
                LEFT JOIN chantiers c ON c.id = dm.chantier_id
                WHERE 1=1';
        $params = [];

        if (!empty($filtre['chantier_id'])) {
            $sql .= ' AND dm.chantier_id = :chantier_id';
            $params['chantier_id'] = (int) $filtre['chantier_id'];
        }
        if (!empty($filtre['statut'])) {
            $sql .= ' AND dm.statut = :statut';
            $params['statut'] = $filtre['statut'];
        }
        if (!empty($filtre['urgence'])) {
            $sql .= ' AND dm.urgence = :urgence';
            $params['urgence'] = $filtre['urgence'];
        }
        if (!empty($filtre['recherche'])) {
            $sql .= " AND (
                dm.numero LIKE :recherche_numero
                OR dm.objet LIKE :recherche_objet
                OR c.nom LIKE :recherche_chantier
                OR CONCAT_WS(' ', u.prenom, u.nom) LIKE :recherche_demandeur
                OR dm.urgence LIKE :recherche_urgence
                OR dm.statut LIKE :recherche_statut
                OR CAST(dm.date_demande AS CHAR) LIKE :recherche_date
                OR DATE_FORMAT(dm.date_demande, '%d/%m/%Y') LIKE :recherche_date_fr
            )";
            $terme = '%' . trim((string) $filtre['recherche']) . '%';
            foreach ([
                'numero',
                'objet',
                'chantier',
                'demandeur',
                'urgence',
                'statut',
                'date',
                'date_fr',
            ] as $champ) {
                $params['recherche_' . $champ] = $terme;
            }
        }

        $sql .= ' ORDER BY dm.cree_le DESC';
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function trouver(int $id): ?array
    {
        $pdo = Database::connexion();
        $stmt = $pdo->prepare('SELECT * FROM demandes_materiel WHERE id = :id');
        $stmt->execute(['id' => $id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return $row === false ? null : $row;
    }

    public function trouverAvecLignes(int $id): ?array
    {
        $demande = $this->trouver($id);
        if ($demande === null) {
            return null;
        }
        $pdo = Database::connexion();
        $stmt = $pdo->prepare('SELECT * FROM demandes_materiel_lignes WHERE demande_id = :id ORDER BY id ASC');
        $stmt->execute(['id' => $id]);
        $demande['lignes'] = $stmt->fetchAll(PDO::FETCH_ASSOC);
        return $demande;
    }

    public function creerAvecLignes(array $entete, array $lignes): int
    {
        $pdo = Database::connexion();
        $gereTransaction = !$pdo->inTransaction();
        if ($gereTransaction) {
            $pdo->beginTransaction();
        }
        try {
            $stmt = $pdo->prepare('INSERT INTO demandes_materiel (numero, chantier_id, demandeur_id, objet, urgence, statut, date_demande, notes)
                                   VALUES (:numero, :chantier_id, :demandeur_id, :objet, :urgence, :statut, :date_demande, :notes)');
            $stmt->execute([
                'numero'       => $entete['numero'],
                'chantier_id'  => $entete['chantier_id'],
                'demandeur_id' => $entete['demandeur_id'],
                'objet'        => $entete['objet'],
                'urgence'      => $entete['urgence'],
                'statut'       => $entete['statut'],
                'date_demande' => $entete['date_demande'],
                'notes'        => $entete['notes'] ?? null,
            ]);
            $id = (int) $pdo->lastInsertId();

            $stmtLigne = $pdo->prepare('INSERT INTO demandes_materiel_lignes (demande_id, materiau_id, designation, unite, quantite_demandee, prix_unitaire)
                                        VALUES (:demande_id, :materiau_id, :designation, :unite, :quantite_demandee, :prix_unitaire)');
            foreach ($lignes as $ligne) {
                if (empty($ligne['designation'])) {
                    continue;
                }
                $stmtLigne->execute([
                    'demande_id'       => $id,
                    'materiau_id'      => $ligne['materiau_id'] ?? null,
                    'designation'      => $ligne['designation'],
                    'unite'            => $ligne['unite'] ?? 'U',
                    'quantite_demandee'=> $ligne['quantite_demandee'] ?? 0,
                    'prix_unitaire'    => $ligne['prix_unitaire'] ?? 0,
                ]);
            }

            if ($gereTransaction) {
                $pdo->commit();
            }
            return $id;
        } catch (\Throwable $e) {
            if ($gereTransaction && $pdo->inTransaction()) {
                $pdo->rollBack();
            }
            throw $e;
        }
    }

    public function modifier(int $id, array $donnees): bool
    {
        $pdo = Database::connexion();
        $champs = [];
        $params = ['id' => $id];
        foreach (['statut', 'magasinier_id', 'motif_refus', 'date_traitement', 'notes'] as $champ) {
            if (array_key_exists($champ, $donnees)) {
                $champs[] = "$champ = :$champ";
                $params[$champ] = $donnees[$champ];
            }
        }
        if ($champs === []) {
            return false;
        }
        $sql = 'UPDATE demandes_materiel SET ' . implode(', ', $champs) . ' WHERE id = :id';
        return $pdo->prepare($sql)->execute($params);
    }

    public static function genererNumero(): string
    {
        return 'DM-' . date('Ymd-His') . '-' . strtoupper(substr(bin2hex(random_bytes(2)), 0, 4));
    }
}
