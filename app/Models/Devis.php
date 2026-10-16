<?php

namespace App\Models;

use App\Core\DocumentModel;
use PDO;

/** Modele des devis. */
final class Devis extends DocumentModel
{
    protected string $table = 'devis';
    protected string $tableLignes = 'devis_lignes';
    protected string $colonneFk = 'devis_id';

    /** @return array{lignes:array<int,array<string,mixed>>,total:int} */
    public function liste(string $terme, int $limite, int $decalage): array
    {
        $where = '';
        $params = [];
        $terme = trim($terme);
        if ($terme !== '') {
            $where = 'WHERE d.reference LIKE :t0 OR c.nom LIKE :t1';
            $params = [':t0' => "%$terme%", ':t1' => "%$terme%"];
        }
        $jointure = 'LEFT JOIN clients c ON c.id = d.client_id';

        $reqTotal = $this->db()->prepare("SELECT COUNT(*) FROM devis d $jointure $where");
        $reqTotal->execute($params);
        $total = (int) $reqTotal->fetchColumn();

        $req = $this->db()->prepare("SELECT d.*, c.nom AS client_nom FROM devis d $jointure $where
                                     ORDER BY d.id DESC LIMIT :limite OFFSET :decalage");
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
        $req = $this->db()->prepare('SELECT d.*, c.nom AS client_nom, ch.nom AS chantier_nom
                                     FROM devis d
                                     LEFT JOIN clients c ON c.id = d.client_id
                                     LEFT JOIN chantiers ch ON ch.id = d.chantier_id
                                     WHERE d.id = :id LIMIT 1');
        $req->execute([':id' => $id]);
        $devis = $req->fetch();
        if (!$devis) {
            return null;
        }
        $devis['lignes'] = $this->lignes($id);
        return $devis;
    }
}
