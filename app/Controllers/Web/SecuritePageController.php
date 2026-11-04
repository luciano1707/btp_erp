<?php

namespace App\Controllers\Web;

use App\Core\Access;
use App\Core\Controller;
use App\Core\Request;
use App\Core\Response;

final class SecuritePageController extends Controller
{
    public function liste(Request $requete): void
    {
        $role = $requete->auth['role'] ?? null;
        Response::vue('securite.liste', [
            'titre'     => 'Securite',
            'peutCreer' => Access::autorise($role, 'securite', 'create'),
        ]);
    }

    public function formulaire(Request $requete): void
    {
        Response::vue('securite.formulaire', ['titre' => 'Nouvelle observation securite']);
    }

    public function detail(Request $requete): void
    {
        $role = $requete->auth['role'] ?? null;
        Response::vue('securite.detail', [
            'titre'        => 'Detail securite',
            'id'           => $requete->params['id'] ?? null,
            'peutModifier' => Access::autorise($role, 'securite', 'edit'),
        ]);
    }
}
