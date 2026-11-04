<?php

namespace App\Models;

use App\Core\Database;
use PDO;

final class Budget
{
    /** @param array<string,mixed> $filtre */
    public function liste(array $filtre = []): array
    {
        $pdo = Database::connexion();
        $sql = 'SELECT b.*, c.nom AS chantier_nom, c.code AS chantier_code,
                       COALESCE((SELECT SUM(l.montant_prevu) FROM budget_lignes l WHERE l.budget_id = b.id), 0) AS total_lignes,
                       COALESCE((SELECT SUM(l.montant_engage) FROM budget_lignes l WHERE l.budget_id = b.id), 0) AS total_engage,
                       COALESCE((SELECT SUM(l.montant_reel) FROM budget_lignes l WHERE l.budget_id = b.id), 0) AS total_reel,
                       COALESCE((SELECT SUM(d.montant) FROM depenses d
                                 WHERE d.chantier_id = b.chantier_id
                                   AND YEAR(d.date_depense) = b.annee
                                   AND d.statut IN ("valide", "comptabilise")), 0) AS depenses_validees
                FROM budgets b
                LEFT JOIN chantiers c ON c.id = b.chantier_id
                WHERE 1=1';
        $params = [];
        if (!empty($filtre['chantier_id'])) {
            $sql .= ' AND b.chantier_id = :chantier_id';
            $params['chantier_id'] = (int) $filtre['chantier_id'];
        }
        if (!empty($filtre['annee'])) {
            $sql .= ' AND b.annee = :annee';
            $params['annee'] = (int) $filtre['annee'];
        }
        if (!empty($filtre['statut'])) {
            $sql .= ' AND b.statut = :statut';
            $params['statut'] = $filtre['statut'];
        }
        $sql .= ' ORDER BY b.annee DESC, b.id DESC';
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function trouverAvecLignes(int $id): ?array
    {
        $pdo = Database::connexion();
        $stmt = $pdo->prepare('SELECT b.*, c.nom AS chantier_nom, c.code AS chantier_code
                               FROM budgets b
                               LEFT JOIN chantiers c ON c.id = b.chantier_id
                               WHERE b.id = :id');
        $stmt->execute(['id' => $id]);
        $budget = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($budget === false) {
            return null;
        }

        $stmt = $pdo->prepare('SELECT * FROM budget_lignes WHERE budget_id = :id ORDER BY id ASC');
        $stmt->execute(['id' => $id]);
        $budget['lignes'] = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $stmt = $pdo->prepare('SELECT COALESCE(SUM(montant), 0) FROM depenses
                               WHERE chantier_id = :chantier_id
                                 AND YEAR(date_depense) = :annee
                                 AND statut IN ("valide", "comptabilise")');
        $stmt->execute(['chantier_id' => $budget['chantier_id'], 'annee' => $budget['annee']]);
        $budget['depenses_validees'] = (float) $stmt->fetchColumn();

        return $budget;
    }

    /**
     * @param array<string,mixed> $entete
     * @param array<int,array<string,mixed>> $lignes
     */
    public function creerAvecLignes(array $entete, array $lignes = []): int
    {
        $pdo = Database::connexion();
        $pdo->beginTransaction();
        try {
            $stmt = $pdo->prepare('INSERT INTO budgets
                (chantier_id, annee, budget_previsionnel, budget_revision, devise, statut, notes, cree_par)
                VALUES
                (:chantier_id, :annee, :budget_previsionnel, :budget_revision, :devise, :statut, :notes, :cree_par)');
            $stmt->execute([
                'chantier_id'         => $entete['chantier_id'],
                'annee'               => $entete['annee'],
                'budget_previsionnel' => $entete['budget_previsionnel'],
                'budget_revision'     => $entete['budget_revision'] ?? 0,
                'devise'              => $entete['devise'] ?? 'MGA',
                'statut'              => $entete['statut'] ?? 'ouvert',
                'notes'               => $entete['notes'] ?? null,
                'cree_par'            => $entete['cree_par'] ?? null,
            ]);
            $id = (int) $pdo->lastInsertId();
            $this->remplacerLignes($pdo, $id, $lignes);
            $pdo->commit();
            return $id;
        } catch (\Throwable $e) {
            $pdo->rollBack();
            throw $e;
        }
    }

    /**
     * @param array<string,mixed> $entete
     * @param array<int,array<string,mixed>>|null $lignes
     */
    public function modifierAvecLignes(int $id, array $entete, ?array $lignes = null): bool
    {
        $pdo = Database::connexion();
        $pdo->beginTransaction();
        try {
            $autorises = ['budget_previsionnel', 'budget_revision', 'devise', 'statut', 'notes'];
            $champs = [];
            $params = ['id' => $id];
            foreach ($autorises as $champ) {
                if (array_key_exists($champ, $entete)) {
                    $champs[] = "$champ = :$champ";
                    $params[$champ] = $entete[$champ];
                }
            }
            if ($champs !== []) {
                $pdo->prepare('UPDATE budgets SET ' . implode(', ', $champs) . ' WHERE id = :id')->execute($params);
            }
            if ($lignes !== null) {
                $this->remplacerLignes($pdo, $id, $lignes);
            }
            $pdo->commit();
            return true;
        } catch (\Throwable $e) {
            $pdo->rollBack();
            throw $e;
        }
    }

    /** @param array<int,array<string,mixed>> $lignes */
    private function remplacerLignes(PDO $pdo, int $budgetId, array $lignes): void
    {
        $pdo->prepare('DELETE FROM budget_lignes WHERE budget_id = :id')->execute(['id' => $budgetId]);
        $stmt = $pdo->prepare('INSERT INTO budget_lignes
            (budget_id, rubrique, montant_prevu, montant_engage, montant_reel)
            VALUES (:budget_id, :rubrique, :montant_prevu, :montant_engage, :montant_reel)');
        foreach ($lignes as $ligne) {
            if (empty($ligne['rubrique'])) {
                continue;
            }
            $stmt->execute([
                'budget_id'      => $budgetId,
                'rubrique'       => $ligne['rubrique'],
                'montant_prevu'  => $ligne['montant_prevu'] ?? 0,
                'montant_engage' => $ligne['montant_engage'] ?? 0,
                'montant_reel'   => $ligne['montant_reel'] ?? 0,
            ]);
        }
    }
}
