<?php

namespace App\Controllers\Web;

use App\Core\Controller;
use App\Core\Env;
use App\Core\Request;
use App\Core\Response;

/**
 * Page d'accueil web (tableau de bord provisoire de la Phase 0).
 */
final class HomeController extends Controller
{
    public function index(Request $requete): void
    {
        if (Env::get('APP_DESKTOP', false) === true) {
            Response::rediriger(\url('/connexion'));
        }

        Response::vue('accueil', [
            'titre'       => 'Accueil',
            'application' => Env::get('APP_NAME', 'Digital Chantier'),
        ]);
    }
}
