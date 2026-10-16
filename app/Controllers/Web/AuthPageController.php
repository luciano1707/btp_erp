<?php

namespace App\Controllers\Web;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Response;

/**
 * Pages web liees a l'authentification.
 * Ces pages sont de simples coquilles HTML : la logique d'auth passe par l'API (JWT),
 * pilotee cote navigateur par assets/js/auth.js.
 */
final class AuthPageController extends Controller
{
    /** GET /connexion */
    public function connexion(Request $requete): void
    {
        Response::vue('auth.connexion', ['titre' => 'Connexion']);
    }

    /** GET /mot-de-passe-oublie */
    public function motDePasseOublie(Request $requete): void
    {
        Response::vue('auth.mot-de-passe-oublie', ['titre' => 'Mot de passe oublie']);
    }

    /** GET /tableau-de-bord */
    public function tableauDeBord(Request $requete): void
    {
        Response::vue('tableau_de_bord', ['titre' => 'Tableau de bord']);
    }
}
