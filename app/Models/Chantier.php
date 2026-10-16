<?php

namespace App\Models;

use App\Core\Model;
use PDO;

/**
 * Modele des chantiers. Ajoute les jointures vers client et responsable
 * pour afficher leurs noms sans requetes supplementaires cote client.
 */
final class Chantier extends Model
{
    protected string $table = 'chantiers';

    private const JOINTURES =
        'LEFT JOIN clients cl ON cl.id = c.client_id
         LEFT JOIN utilisateurs u ON u.id = c.responsable_id';

    private const COLONNES =
        "c.*, cl.nom AS client_nom,
         NULLIF(TRIM(CONCAT(COALESCE(u.prenom,''),' ',COALESCE(u.nom,''))), '') AS responsable_nom";

    /**
     * Liste paginee des chantiers avec noms du client et du responsable.
     *
     * @return array{lignes:array<int,array<string,mixed>>,total:int}
     */
    public function listeAvecRelations(string $terme, int $limite, int $decalage): array
    {
        $terme = trim($terme);
        $where = '';
        $params = [];

        if ($terme !== '') {
            $colonnes = ['c.code', 'c.nom', 'c.localisation', 'cl.nom'];
            $conditions = [];
            foreach ($colonnes as $i => $colonne) {
                $conditions[] = "$colonne LIKE :t$i";
                $params[":t$i"] = "%$terme%";
            }
            $where = 'WHERE ' . implode(' OR ', $conditions);
        }

        $reqTotal = $this->db()->prepare("SELECT COUNT(*) FROM chantiers c " . self::JOINTURES . " $where");
        $reqTotal->execute($params);
        $total = (int) $reqTotal->fetchColumn();

        $sql = 'SELECT ' . self::COLONNES . ' FROM chantiers c ' . self::JOINTURES . " $where
                ORDER BY c.id DESC LIMIT :limite OFFSET :decalage";
        $req = $this->db()->prepare($sql);
        foreach ($params as $ph => $valeur) {
            $req->bindValue($ph, $valeur);
        }
        $req->bindValue(':limite', $limite, PDO::PARAM_INT);
        $req->bindValue(':decalage', $decalage, PDO::PARAM_INT);
        $req->execute();

        return ['lignes' => $req->fetchAll(), 'total' => $total];
    }

    /** Un chantier avec noms du client et du responsable. @return array<string,mixed>|null */
    public function trouverAvecRelations(int $id): ?array
    {
        $sql = 'SELECT ' . self::COLONNES . ' FROM chantiers c ' . self::JOINTURES . ' WHERE c.id = :id LIMIT 1';
        $req = $this->db()->prepare($sql);
        $req->execute([':id' => $id]);
        $ligne = $req->fetch();
        return $ligne ?: null;
    }
}
