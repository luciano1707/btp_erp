<?php

namespace App\Models;

use App\Core\Database;
use PDO;

final class Rfi
{
    /** @param array<string,mixed> $filtre */
    public function liste(array $filtre = []): array
    {
        $pdo = Database::connexion();
        $sql = 'SELECT r.*, c.nom AS chantier_nom, c.code AS chantier_code,
                       TRIM(CONCAT(COALESCE(u.prenom, ""), " ", COALESCE(u.nom, ""))) AS emetteur_nom,
                       TRIM(CONCAT(COALESCE(v.prenom, ""), " ", COALESCE(v.nom, ""))) AS repondeur_nom
                FROM rfi r
                LEFT JOIN chantiers c ON c.id = r.chantier_id
                LEFT JOIN utilisateurs u ON u.id = r.emetteur_id
                LEFT JOIN utilisateurs v ON v.id = r.repondu_par
                WHERE 1=1';
        $params = [];
        foreach (['chantier_id', 'statut', 'priorite'] as $champ) {
            if (!empty($filtre[$champ])) {
                $sql .= " AND r.$champ = :$champ";
                $params[$champ] = $filtre[$champ];
            }
        }
        $sql .= ' ORDER BY r.cree_le DESC';
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function trouverAvecDetails(int $id): ?array
    {
        $pdo = Database::connexion();
        $sql = 'SELECT r.*, c.nom AS chantier_nom, c.code AS chantier_code,
                       TRIM(CONCAT(COALESCE(u.prenom, ""), " ", COALESCE(u.nom, ""))) AS emetteur_nom,
                       TRIM(CONCAT(COALESCE(v.prenom, ""), " ", COALESCE(v.nom, ""))) AS repondeur_nom
                FROM rfi r
                LEFT JOIN chantiers c ON c.id = r.chantier_id
                LEFT JOIN utilisateurs u ON u.id = r.emetteur_id
                LEFT JOIN utilisateurs v ON v.id = r.repondu_par
                WHERE r.id = :id';
        $stmt = $pdo->prepare($sql);
        $stmt->execute(['id' => $id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return $row === false ? null : $row;
    }

    /** @param array<string,mixed> $donnees */
    public function creer(array $donnees): int
    {
        $pdo = Database::connexion();
        $stmt = $pdo->prepare('INSERT INTO rfi
            (numero, chantier_id, emetteur_id, objet, question, priorite, date_limite, statut)
            VALUES
            (:numero, :chantier_id, :emetteur_id, :objet, :question, :priorite, :date_limite, :statut)');
        $stmt->execute([
            'numero'      => $donnees['numero'],
            'chantier_id' => $donnees['chantier_id'],
            'emetteur_id' => $donnees['emetteur_id'],
            'objet'       => $donnees['objet'],
            'question'    => $donnees['question'],
            'priorite'    => $donnees['priorite'] ?? 'normale',
            'date_limite' => $donnees['date_limite'] ?? null,
            'statut'      => $donnees['statut'] ?? 'ouvert',
        ]);
        return (int) $pdo->lastInsertId();
    }

    public function repondre(int $id, int $utilisateurId, string $reponse): bool
    {
        $pdo = Database::connexion();
        $stmt = $pdo->prepare('UPDATE rfi
                               SET reponse = :reponse, repondu_par = :utilisateur, repondu_le = :date, statut = "repondu"
                               WHERE id = :id');
        return $stmt->execute([
            'reponse'     => $reponse,
            'utilisateur' => $utilisateurId,
            'date'        => date('Y-m-d H:i:s'),
            'id'          => $id,
        ]);
    }

    public static function genererNumero(): string
    {
        return 'RFI-' . date('Ymd-His') . '-' . strtoupper(substr(bin2hex(random_bytes(2)), 0, 4));
    }
}
