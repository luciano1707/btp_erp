<?php

namespace App\Middleware;

use App\Core\Access;
use App\Core\Request;
use App\Core\Response;

/** Vérifie une permission de la matrice RBAC après AuthMiddleware. */
final class PermissionMiddleware
{
    public function traiter(Request $requete, string $module, string $action = 'view'): void
    {
        if (!Access::autorise($requete->auth['role'] ?? null, $module, $action)) {
            if ($requete->estApi()) {
                Response::erreur('Acces refuse : permission insuffisante.', 403);
            }
            Response::vue('erreurs.403', ['module' => $module], 403);
        }
    }
}
