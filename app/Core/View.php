<?php

namespace App\Core;

use RuntimeException;

/**
 * Moteur de rendu de vues PHP simple.
 * Les vues residents dans app/Views. Le nom accepte la notation pointee
 * (ex: "layouts.base" => app/Views/layouts/base.php).
 */
final class View
{
    /**
     * Rend une vue avec les donnees fournies (extraites en variables locales).
     *
     * @param array<string,mixed> $donnees
     */
    public static function rendre(string $vue, array $donnees = []): void
    {
        $chemin = dirname(__DIR__) . '/Views/' . str_replace('.', '/', $vue) . '.php';

        if (!is_file($chemin)) {
            throw new RuntimeException("Vue introuvable : $vue");
        }

        extract($donnees, EXTR_SKIP);
        require $chemin;
    }

    /**
     * Rend une vue et retourne le HTML sous forme de chaine (utile pour l'inserer dans un layout).
     *
     * @param array<string,mixed> $donnees
     */
    public static function capturer(string $vue, array $donnees = []): string
    {
        ob_start();
        self::rendre($vue, $donnees);
        return (string) ob_get_clean();
    }
}
