<?php

/**
 * Point d'entree unique de l'application (front controller).
 * Place a la racine du projet : le domaine (ou le sous-dossier XAMPP) pointe directement ici.
 * Toutes les requetes web et API transitent par ce fichier.
 */

declare(strict_types=1);

use App\Core\App;
use App\Core\Autoloader;
use App\Core\Env;

$racine = __DIR__;

// Serveur PHP integre (php -S) : laisser servir les fichiers statiques reels.
// (En production, Apache s'en charge via .htaccess ; ce bloc est ignore.)
if (PHP_SAPI === 'cli-server') {
    $fichier = $racine . parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
    if (is_file($fichier)) {
        return false;
    }
}

// 1. Autoloader maison (namespace App\ => app/)
require $racine . '/app/Core/Autoloader.php';
Autoloader::enregistrer($racine);
require $racine . '/vendor/autoload.php';

// 2. Variables d'environnement
Env::charger($racine . '/.env');

// 3. Fonctions d'aide globales
require $racine . '/app/Helpers/format.php';

// 4. Demarrage de l'application
(new App($racine))->executer();
