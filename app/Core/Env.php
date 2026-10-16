<?php

namespace App\Core;

/**
 * Chargeur de variables d'environnement (.env).
 * Implementation minimaliste, sans dependance externe (compatible hebergement mutualise).
 */
final class Env
{
    /** Indique si le fichier .env a deja ete charge. */
    private static bool $charge = false;

    /**
     * Charge le fichier .env dans $_ENV et l'environnement PHP.
     */
    public static function charger(string $chemin): void
    {
        if (self::$charge || !is_readable($chemin)) {
            return;
        }

        $lignes = file($chemin, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
        foreach ($lignes as $ligne) {
            $ligne = trim($ligne);

            // Ignorer les commentaires et les lignes sans affectation
            if ($ligne === '' || str_starts_with($ligne, '#') || !str_contains($ligne, '=')) {
                continue;
            }

            [$cle, $valeur] = explode('=', $ligne, 2);
            $cle = trim($cle);
            $valeur = trim($valeur);

            // Retirer les guillemets englobants eventuels
            if (strlen($valeur) >= 2) {
                $premier = $valeur[0];
                $dernier = $valeur[strlen($valeur) - 1];
                if (($premier === '"' && $dernier === '"') || ($premier === "'" && $dernier === "'")) {
                    $valeur = substr($valeur, 1, -1);
                }
            }

            $_ENV[$cle] = $valeur;
            putenv("$cle=$valeur");
        }

        self::$charge = true;
    }

    /**
     * Recupere une variable d'environnement, avec conversion des booleens/nuls textuels.
     */
    public static function get(string $cle, mixed $defaut = null): mixed
    {
        $valeur = $_ENV[$cle] ?? getenv($cle);
        if ($valeur === false || $valeur === null || $valeur === '') {
            return $defaut;
        }

        return match (strtolower((string) $valeur)) {
            'true'  => true,
            'false' => false,
            'null'  => null,
            default => $valeur,
        };
    }
}
