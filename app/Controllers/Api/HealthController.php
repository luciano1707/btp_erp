<?php

namespace App\Controllers\Api;

use App\Core\Controller;
use App\Core\Database;
use App\Core\Env;
use App\Core\Request;
use App\Core\Response;
use Throwable;

/**
 * Point de controle de sante de l'API.
 * Permet de verifier, cote client (web ou mobile), que l'API et la base repondent.
 */
final class HealthController extends Controller
{
    public function index(Request $requete): void
    {
        $etatBase = 'indisponible';
        try {
            Database::connexion()->query('SELECT 1');
            $etatBase = 'connectee';
        } catch (Throwable $e) {
            $etatBase = 'erreur';
        }

        Response::succes([
            'application'   => Env::get('APP_NAME', 'Digital Chantier'),
            'version_api'   => 'v1',
            'php'           => PHP_VERSION,
            'base_donnees'  => $etatBase,
            'environnement' => Env::get('APP_ENV', 'local'),
            'horodatage'    => date('c'),
        ], 'API operationnelle');
    }
}
