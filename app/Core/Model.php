<?php

namespace App\Core;

use PDO;

/**
 * Modele de base : acces CRUD generique via PDO.
 * Les modeles enfants definissent $table et, si besoin, $champsAutorises (garde anti-injection en masse).
 */
abstract class Model
{
    /** Nom de la table SQL. */
    protected string $table = '';

    /** Nom de la cle primaire. */
    protected string $cle = 'id';

    protected function db(): PDO
    {
        return Database::connexion();
    }

    /** Retourne toutes les lignes (avec limite de securite par defaut). @return array<int,array<string,mixed>> */
    public function tout(int $limite = 500, int $decalage = 0): array
    {
        $req = $this->db()->prepare("SELECT * FROM {$this->table} ORDER BY {$this->cle} DESC LIMIT :limite OFFSET :decalage");
        $req->bindValue(':limite', $limite, PDO::PARAM_INT);
        $req->bindValue(':decalage', $decalage, PDO::PARAM_INT);
        $req->execute();
        return $req->fetchAll();
    }

    /** Nombre total de lignes de la table. */
    public function compter(): int
    {
        return (int) $this->db()->query("SELECT COUNT(*) FROM {$this->table}")->fetchColumn();
    }

    /**
     * Recherche paginee sur un ensemble de colonnes (LIKE).
     *
     * @param string[] $colonnes Colonnes sur lesquelles chercher
     * @return array{lignes:array<int,array<string,mixed>>,total:int}
     */
    public function chercher(array $colonnes, string $terme, int $limite = 50, int $decalage = 0): array
    {
        $terme = trim($terme);

        if ($terme === '' || $colonnes === []) {
            return [
                'lignes' => $this->tout($limite, $decalage),
                'total'  => $this->compter(),
            ];
        }

        // Un placeholder UNIQUE par colonne : en requetes preparees natives, MySQL
        // n'autorise pas la reutilisation d'un meme parametre nomme (:t0, :t1, ...).
        // Les noms de colonnes sont controles par le code (jamais par l'utilisateur).
        $conditions = [];
        $params = [];
        foreach (array_values($colonnes) as $i => $colonne) {
            $ph = ":t$i";
            $conditions[] = "$colonne LIKE $ph";
            $params[$ph] = "%$terme%";
        }
        $sqlBase = "FROM {$this->table} WHERE " . implode(' OR ', $conditions);

        $reqTotal = $this->db()->prepare("SELECT COUNT(*) $sqlBase");
        $reqTotal->execute($params);
        $total = (int) $reqTotal->fetchColumn();

        $req = $this->db()->prepare("SELECT * $sqlBase ORDER BY {$this->cle} DESC LIMIT :limite OFFSET :decalage");
        foreach ($params as $ph => $valeur) {
            $req->bindValue($ph, $valeur);
        }
        $req->bindValue(':limite', $limite, PDO::PARAM_INT);
        $req->bindValue(':decalage', $decalage, PDO::PARAM_INT);
        $req->execute();

        return ['lignes' => $req->fetchAll(), 'total' => $total];
    }

    /** Retourne une ligne par cle primaire, ou null. @return array<string,mixed>|null */
    public function trouver(int|string $id): ?array
    {
        $req = $this->db()->prepare("SELECT * FROM {$this->table} WHERE {$this->cle} = :id LIMIT 1");
        $req->execute([':id' => $id]);
        $ligne = $req->fetch();
        return $ligne ?: null;
    }

    /**
     * Insere une ligne et retourne son identifiant.
     *
     * @param array<string,mixed> $donnees
     */
    public function creer(array $donnees): int
    {
        $colonnes = array_keys($donnees);
        $marqueurs = array_map(static fn ($c) => ":$c", $colonnes);

        $sql = sprintf(
            'INSERT INTO %s (%s) VALUES (%s)',
            $this->table,
            implode(', ', $colonnes),
            implode(', ', $marqueurs)
        );

        $this->db()->prepare($sql)->execute($this->lier($donnees));
        return (int) $this->db()->lastInsertId();
    }

    /**
     * Met a jour une ligne par cle primaire.
     *
     * @param array<string,mixed> $donnees
     */
    public function modifier(int|string $id, array $donnees): bool
    {
        $affectations = array_map(static fn ($c) => "$c = :$c", array_keys($donnees));
        $sql = sprintf(
            'UPDATE %s SET %s WHERE %s = :cle_primaire',
            $this->table,
            implode(', ', $affectations),
            $this->cle
        );

        $params = $this->lier($donnees);
        $params[':cle_primaire'] = $id;
        return $this->db()->prepare($sql)->execute($params);
    }

    /** Supprime une ligne par cle primaire. */
    public function supprimer(int|string $id): bool
    {
        $req = $this->db()->prepare("DELETE FROM {$this->table} WHERE {$this->cle} = :id");
        return $req->execute([':id' => $id]);
    }

    /** Prefixe les cles avec ':' pour les parametres nommes PDO. @return array<string,mixed> */
    private function lier(array $donnees): array
    {
        $params = [];
        foreach ($donnees as $cle => $valeur) {
            $params[":$cle"] = $valeur;
        }
        return $params;
    }
}
