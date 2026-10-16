<?php

namespace App\Core;

/**
 * Autoloader PSR-4 maison : mappe le namespace "App\" vers le dossier "app/".
 * Exemple : App\Controllers\Api\HealthController => app/Controllers/Api/HealthController.php
 */
final class Autoloader
{
    /**
     * @param string $racine Chemin absolu de la racine du projet (dossier contenant "app/").
     */
    public static function enregistrer(string $racine): void
    {
        spl_autoload_register(static function (string $classe) use ($racine): void {
            $prefixe = 'App\\';
            if (!str_starts_with($classe, $prefixe)) {
                return;
            }

            $relatif = substr($classe, strlen($prefixe));
            $chemin = $racine . '/app/' . str_replace('\\', '/', $relatif) . '.php';

            if (is_file($chemin)) {
                require $chemin;
            }
        });
    }
}
