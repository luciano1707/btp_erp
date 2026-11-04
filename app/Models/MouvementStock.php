<?php

namespace App\Models;

use App\Core\Model;

/** Modele des mouvements de stock (entrees / sorties / ajustements). */
final class MouvementStock extends Model
{
    protected string $table = 'mouvements_stock';

    /** Enregistre un mouvement. */
    public function enregistrer(array $donnees): int
    {
        return $this->creer($donnees);
    }

    /** Stock courant d'un materiau : entrees - sorties (+/- ajustements). */
    public function stock(int $materiauId): float
    {
        $req = $this->db()->prepare(
            "SELECT COALESCE(SUM(CASE
                        WHEN type = 'entree' THEN quantite
                        WHEN type = 'sortie' THEN -quantite
                        ELSE quantite END), 0)
             FROM mouvements_stock WHERE materiau_id = :m AND statut = 'valide'"
        );
        $req->execute([':m' => $materiauId]);
        return (float) $req->fetchColumn();
    }

    /**
     * Etat du stock pour tous les materiaux actifs (stock courant + seuil d'alerte).
     * @return array<int,array<string,mixed>>
     */
    public function etatStock(): array
    {
        $sql = "SELECT m.id, m.code, m.designation, m.unite, m.seuil_alerte,
                       COALESCE(SUM(CASE
                            WHEN mv.type = 'entree' THEN mv.quantite
                            WHEN mv.type = 'sortie' THEN -mv.quantite
                            ELSE mv.quantite END), 0) AS stock
                FROM materiaux m
                LEFT JOIN mouvements_stock mv ON mv.materiau_id = m.id AND mv.statut = 'valide'
                WHERE m.actif = 1
                GROUP BY m.id, m.code, m.designation, m.unite, m.seuil_alerte
                ORDER BY m.designation ASC";
        return $this->db()->query($sql)->fetchAll();
    }

    /** Derniers mouvements d'un materiau. @return array<int,array<string,mixed>> */
    public function historique(int $materiauId, int $limite = 50): array
    {
        $req = $this->db()->prepare(
            'SELECT mv.*, c.nom AS chantier_nom
             FROM mouvements_stock mv
             LEFT JOIN chantiers c ON c.id = mv.chantier_id
             WHERE mv.materiau_id = :m ORDER BY mv.id DESC LIMIT :lim'
        );
        $req->bindValue(':m', $materiauId, \PDO::PARAM_INT);
        $req->bindValue(':lim', $limite, \PDO::PARAM_INT);
        $req->execute();
        return $req->fetchAll();
    }
}
