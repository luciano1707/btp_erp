<?php

namespace App\Core;

use PDO;

/**
 * Gestionnaire de migrations SQL.
 * - Cree la base si absente.
 * - Rejoue les fichiers .sql de database/migrations non encore appliques.
 * - Trace l'historique dans la table "migrations".
 *
 * Les fichiers sont executes dans l'ordre alphabetique (d'ou la numerotation 0001_, 0002_, ...).
 */
final class Migrator
{
    private string $dossierMigrations;

    public function __construct(string $racine)
    {
        $this->dossierMigrations = $racine . '/database/migrations';
    }

    /** Cree la base de donnees applicative si elle n'existe pas. */
    public function assurerBase(): void
    {
        $nom = (string) Env::get('DB_NAME', 'btp_erp');
        $charset = (string) Env::get('DB_CHARSET', 'utf8mb4');

        $serveur = Database::connexionServeur();
        $serveur->exec(
            "CREATE DATABASE IF NOT EXISTS `$nom` CHARACTER SET $charset COLLATE {$charset}_unicode_ci"
        );
        $this->log("Base « $nom » verifiee / creee.");
    }

    /** Cree la table de suivi des migrations si absente. */
    private function assurerTableSuivi(PDO $db): void
    {
        $db->exec(
            'CREATE TABLE IF NOT EXISTS migrations (
                id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                fichier VARCHAR(255) NOT NULL UNIQUE,
                lot INT UNSIGNED NOT NULL,
                execute_le TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci'
        );
    }

    /** Applique les migrations en attente. */
    public function migrer(): void
    {
        $this->assurerBase();
        $db = Database::connexion();
        $this->assurerTableSuivi($db);

        $dejaFaites = $db->query('SELECT fichier FROM migrations')->fetchAll(PDO::FETCH_COLUMN);
        $fichiers = glob($this->dossierMigrations . '/*.sql') ?: [];
        sort($fichiers);

        $lot = (int) $db->query('SELECT COALESCE(MAX(lot), 0) + 1 FROM migrations')->fetchColumn();
        $appliquees = 0;

        foreach ($fichiers as $chemin) {
            $nom = basename($chemin);
            if (in_array($nom, $dejaFaites, true)) {
                continue;
            }

            $sql = file_get_contents($chemin) ?: '';

            // NB : on n'entoure PAS les migrations d'une transaction, car les instructions
            // DDL (CREATE TABLE, ALTER...) declenchent un commit implicite en MySQL/MariaDB,
            // ce qui rendrait tout rollback illusoire. Chaque fichier doit donc etre coherent.
            try {
                foreach ($this->separerRequetes($sql) as $requete) {
                    $db->exec($requete);
                }
                $db->prepare('INSERT INTO migrations (fichier, lot) VALUES (:f, :l)')
                   ->execute([':f' => $nom, ':l' => $lot]);
                $this->log("Applique : $nom");
                $appliquees++;
            } catch (\Throwable $e) {
                $this->log("ECHEC sur $nom : " . $e->getMessage());
                throw $e;
            }
        }

        $this->log($appliquees === 0 ? 'Aucune migration en attente.' : "$appliquees migration(s) appliquee(s).");
    }

    /**
     * Decoupe un script SQL en requetes individuelles.
     * Ignore les commentaires en ligne (-- ...) et respecte les points-virgules.
     * (Suffisant pour nos migrations ; ne gere pas les procedures stockees a delimiteur.)
     *
     * @return string[]
     */
    private function separerRequetes(string $sql): array
    {
        $lignes = preg_split('/\r\n|\r|\n/', $sql) ?: [];
        $sansCommentaires = [];
        foreach ($lignes as $ligne) {
            $sansEspaces = ltrim($ligne);
            // Ligne entierement commentaire
            if (str_starts_with($sansEspaces, '--') || str_starts_with($sansEspaces, '#')) {
                continue;
            }
            // Commentaire inline en fin de ligne (ex: "... DEFAULT 0,   -- explication").
            // Important : un tel commentaire peut contenir un ';' qui casserait le decoupage.
            // (Nos migrations ne contiennent pas de "--" a l'interieur de chaines litterales.)
            $ligne = preg_replace('/\s--\s.*$/', '', $ligne);
            $sansCommentaires[] = $ligne;
        }

        $requetes = array_map('trim', explode(';', implode("\n", $sansCommentaires)));
        return array_filter($requetes, static fn ($r) => $r !== '');
    }

    private function log(string $message): void
    {
        // Sortie console si execute en CLI, sinon journal applicatif.
        if (PHP_SAPI === 'cli') {
            echo "  $message\n";
        }
        Logger::info("[migration] $message");
    }
}
