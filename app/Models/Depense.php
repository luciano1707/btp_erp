<?php

namespace App\Models;

use App\Core\Database;
use PDO;

final class Depense
{
    /** @param array<string,mixed> $filtre */
    public function liste(array $filtre = []): array
    {
        $pdo = Database::connexion();
        $sql = 'SELECT d.*, c.nom AS chantier_nom, c.code AS chantier_code,
                       TRIM(CONCAT(COALESCE(u.prenom, ""), " ", COALESCE(u.nom, ""))) AS declarant_nom,
                       TRIM(CONCAT(COALESCE(v.prenom, ""), " ", COALESCE(v.nom, ""))) AS valideur_nom
                FROM depenses d
                LEFT JOIN chantiers c ON c.id = d.chantier_id
                LEFT JOIN utilisateurs u ON u.id = d.declarant_id
                LEFT JOIN utilisateurs v ON v.id = d.valide_par
                WHERE 1=1';
        $params = [];

        foreach (['chantier_id', 'statut', 'categorie'] as $champ) {
            if (!empty($filtre[$champ])) {
                $sql .= " AND d.$champ = :$champ";
                $params[$champ] = $filtre[$champ];
            }
        }
        if (!empty($filtre['date_debut'])) {
            $sql .= ' AND d.date_depense >= :date_debut';
            $params['date_debut'] = $filtre['date_debut'];
        }
        if (!empty($filtre['date_fin'])) {
            $sql .= ' AND d.date_depense <= :date_fin';
            $params['date_fin'] = $filtre['date_fin'];
        }

        $sql .= ' ORDER BY d.date_depense DESC, d.id DESC';
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function trouverAvecDetails(int $id): ?array
    {
        $pdo = Database::connexion();
        $sql = 'SELECT d.*, c.nom AS chantier_nom, c.code AS chantier_code,
                       TRIM(CONCAT(COALESCE(u.prenom, ""), " ", COALESCE(u.nom, ""))) AS declarant_nom,
                       TRIM(CONCAT(COALESCE(v.prenom, ""), " ", COALESCE(v.nom, ""))) AS valideur_nom
                FROM depenses d
                LEFT JOIN chantiers c ON c.id = d.chantier_id
                LEFT JOIN utilisateurs u ON u.id = d.declarant_id
                LEFT JOIN utilisateurs v ON v.id = d.valide_par
                WHERE d.id = :id';
        $stmt = $pdo->prepare($sql);
        $stmt->execute(['id' => $id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return $row === false ? null : $row;
    }

    /** @param array<string,mixed> $donnees */
    public function creer(array $donnees): int
    {
        $pdo = Database::connexion();
        $stmt = $pdo->prepare('INSERT INTO depenses
            (numero, chantier_id, declarant_id, categorie, libelle, montant, devise,
             date_depense, mode_paiement, beneficiaire, justificatif, statut, notes)
            VALUES
            (:numero, :chantier_id, :declarant_id, :categorie, :libelle, :montant, :devise,
             :date_depense, :mode_paiement, :beneficiaire, :justificatif, :statut, :notes)');
        $stmt->execute([
            'numero'        => $donnees['numero'],
            'chantier_id'   => $donnees['chantier_id'] ?? null,
            'declarant_id'  => $donnees['declarant_id'],
            'categorie'     => $donnees['categorie'],
            'libelle'       => $donnees['libelle'],
            'montant'       => $donnees['montant'],
            'devise'        => $donnees['devise'] ?? 'MGA',
            'date_depense'  => $donnees['date_depense'],
            'mode_paiement' => $donnees['mode_paiement'] ?? null,
            'beneficiaire'  => $donnees['beneficiaire'] ?? null,
            'justificatif'  => $donnees['justificatif'] ?? null,
            'statut'        => $donnees['statut'] ?? 'en_attente',
            'notes'         => $donnees['notes'] ?? null,
        ]);
        return (int) $pdo->lastInsertId();
    }

    /** @param array<string,mixed> $donnees */
    public function modifier(int $id, array $donnees): bool
    {
        $autorises = ['statut', 'valide_par', 'valide_le', 'motif_rejet', 'notes'];
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
        $sql = 'UPDATE depenses SET ' . implode(', ', $champs) . ' WHERE id = :id';
        return Database::connexion()->prepare($sql)->execute($params);
    }

    public static function genererNumero(): string
    {
        return 'DEP-' . date('Ymd-His') . '-' . strtoupper(substr(bin2hex(random_bytes(2)), 0, 4));
    }
}
