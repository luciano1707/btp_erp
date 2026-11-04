<?php

namespace App\Controllers\Web;

use App\Core\Access;
use App\Core\Controller;
use App\Core\Request;
use App\Core\Response;

final class DepensePageController extends Controller
{
    public function liste(Request $requete): void
    {
        $role = $requete->auth['role'] ?? null;
        Response::vue('depenses.liste', [
            'titre'     => 'Depenses',
            'peutCreer' => Access::autorise($role, 'depenses', 'create'),
        ]);
    }

    public function formulaire(Request $requete): void
    {
        Response::vue('depenses.formulaire', ['titre' => 'Nouvelle depense']);
    }

    public function detail(Request $requete): void
    {
        $role = $requete->auth['role'] ?? null;
        Response::vue('depenses.detail', [
            'titre'       => 'Detail depense',
            'id'          => $requete->params['id'] ?? null,
            'peutValider' => Access::autorise($role, 'depenses', 'validate'),
            'roleUtilisateur' => $role,
        ]);
    }
}
