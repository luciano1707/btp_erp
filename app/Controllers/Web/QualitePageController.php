<?php

namespace App\Controllers\Web;

use App\Core\Access;
use App\Core\Controller;
use App\Core\Request;
use App\Core\Response;

final class QualitePageController extends Controller
{
    public function liste(Request $requete): void
    {
        $role = $requete->auth['role'] ?? null;
        Response::vue('qualite.liste', [
            'titre'     => 'Qualite',
            'peutCreer' => Access::autorise($role, 'qualite', 'create'),
        ]);
    }

    public function formulaire(Request $requete): void
    {
        Response::vue('qualite.formulaire', ['titre' => 'Nouvelle inspection qualite']);
    }

    public function detail(Request $requete): void
    {
        $role = $requete->auth['role'] ?? null;
        Response::vue('qualite.detail', [
            'titre'        => 'Detail qualite',
            'id'           => $requete->params['id'] ?? null,
            'peutModifier' => Access::autorise($role, 'qualite', 'edit'),
        ]);
    }
}
