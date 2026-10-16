<?php

namespace App\Models;

use App\Core\Model;

/** Parametres generaux de l'application (stockage cle / valeur). */
final class Parametre extends Model
{
    protected string $table = 'parametres';

    /** Toutes les paires cle => valeur. @return array<string,string|null> */
    public function tous(): array
    {
        $lignes = $this->db()->query('SELECT cle, valeur FROM parametres')->fetchAll();
        $sortie = [];
        foreach ($lignes as $ligne) {
            $sortie[$ligne['cle']] = $ligne['valeur'];
        }
        return $sortie;
    }

    /** Valeur d'un parametre (ou defaut). */
    public function obtenir(string $cle, ?string $defaut = null): ?string
    {
        $req = $this->db()->prepare('SELECT valeur FROM parametres WHERE cle = :c LIMIT 1');
        $req->execute([':c' => $cle]);
        $valeur = $req->fetchColumn();
        return $valeur === false ? $defaut : $valeur;
    }

    /** Cree ou met a jour un parametre. */
    public function definir(string $cle, ?string $valeur): void
    {
        $this->db()->prepare(
            'INSERT INTO parametres (cle, valeur) VALUES (:c, :v)
             ON DUPLICATE KEY UPDATE valeur = :v2'
        )->execute([':c' => $cle, ':v' => $valeur, ':v2' => $valeur]);
    }
}
