<?php

namespace App\Middleware;

use App\Core\Jwt;
use App\Core\Request;
use App\Core\Response;
use App\Models\RefreshToken;
use App\Models\Utilisateur;
use Throwable;

/**
 * Middleware d'authentification.
 * Verifie la presence et la validite d'un access token JWT dans l'entete Authorization.
 * En cas de succes, injecte la charge utile dans $requete->auth.
 */
final class AuthMiddleware
{
    public function traiter(Request $requete): void
    {
        $token = $requete->tokenBearer();

        // Navigation HTML vers une page imprimable : le client ouvre un nouvel onglet et
        // ne peut pas poser d'entete Authorization, il transmet donc l'access token en query.
        if ($token === null && !$requete->estApi() && $requete->methode === 'GET') {
            $token = $requete->jetonUrl();
        }

        if ($token === null) {
            if (!$requete->estApi() && $this->authentifierDepuisCookie($requete)) {
                return;
            }
            if (!$requete->estApi()) {
                Response::vue('erreurs.401', [], 401);
            }
            Response::erreur('Authentification requise.', 401);
        }

        try {
            $charge = Jwt::decoder($token);
        } catch (Throwable $e) {
            if (!$requete->estApi()) {
                Response::vue('erreurs.401', [], 401);
            }
            Response::erreur('Token invalide ou expire.', 401);
        }

        // On refuse un refresh token la ou un access token est attendu
        if (($charge['type'] ?? null) !== 'access') {
            if (!$requete->estApi()) {
                Response::vue('erreurs.401', [], 401);
            }
            Response::erreur('Type de token invalide.', 401);
        }

        $requete->auth = $charge;
    }

    /** Les navigations HTML ne peuvent pas envoyer le Bearer conserve en memoire JS. */
    private function authentifierDepuisCookie(Request $requete): bool
    {
        $token = $requete->cookie('refresh_token');
        if ($token === null || $token === '') {
            return false;
        }

        try {
            $charge = Jwt::decoder($token);
            if (($charge['type'] ?? null) !== 'refresh') {
                return false;
            }
            if ((new RefreshToken())->trouverValide($token) === null) {
                return false;
            }
            $utilisateur = (new Utilisateur())->trouver((int) ($charge['sub'] ?? 0));
            if ($utilisateur === null || !(bool) $utilisateur['actif']) {
                return false;
            }
            $requete->auth = [
                'sub' => (int) $utilisateur['id'],
                'role' => $utilisateur['role'],
                'type' => 'access',
            ];
            return true;
        } catch (Throwable $e) {
            return false;
        }
    }
}
