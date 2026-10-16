<?php

namespace App\Middleware;

use App\Core\Request;
use App\Core\Response;

/**
 * Middleware de controle de role (RBAC).
 * A placer APRES AuthMiddleware (qui a rempli $requete->auth).
 * Usage dans les routes : [RoleMiddleware::class, 'directeur', 'comptable']
 */
final class RoleMiddleware
{
    public function traiter(Request $requete, string ...$rolesAutorises): void
    {
        $role = $requete->auth['role'] ?? null;

        if ($role === null) {
            Response::erreur('Authentification requise.', 401);
        }

        // Le directeur a acces a tout par convention
        if ($role === 'directeur') {
            return;
        }

        if (!in_array($role, $rolesAutorises, true)) {
            Response::erreur('Acces refuse : privileges insuffisants.', 403);
        }
    }
}
