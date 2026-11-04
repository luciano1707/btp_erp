<?php

namespace App\Controllers\Web;

use App\Core\Access;
use App\Core\Controller;
use App\Core\Request;
use App\Core\Response;

final class RfiPageController extends Controller
{
    public function liste(Request $requete): void
    {
        $role = $requete->auth['role'] ?? null;
        Response::vue('rfi.liste', [
            'titre'     => 'RFI',
            'peutCreer' => Access::autorise($role, 'rfi', 'create'),
        ]);
    }

    public function formulaire(Request $requete): void
    {
        Response::vue('rfi.formulaire', ['titre' => 'Nouvelle RFI']);
    }

    public function detail(Request $requete): void
    {
        $role = $requete->auth['role'] ?? null;
        Response::vue('rfi.detail', [
            'titre'         => 'Detail RFI',
            'id'            => $requete->params['id'] ?? null,
            'peutRepondre'  => Access::autorise($role, 'rfi', 'edit'),
        ]);
    }
}
