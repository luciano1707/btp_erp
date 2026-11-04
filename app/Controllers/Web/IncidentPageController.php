<?php

namespace App\Controllers\Web;

use App\Core\Access;
use App\Core\Controller;
use App\Core\Request;
use App\Core\Response;

final class IncidentPageController extends Controller
{
    public function liste(Request $requete): void
    {
        $role = $requete->auth['role'] ?? null;
        Response::vue('incidents.liste', [
            'titre'     => 'Incidents',
            'peutCreer' => Access::autorise($role, 'incidents', 'create'),
        ]);
    }

    public function formulaire(Request $requete): void
    {
        Response::vue('incidents.formulaire', ['titre' => 'Nouvel incident']);
    }

    public function detail(Request $requete): void
    {
        $role = $requete->auth['role'] ?? null;
        Response::vue('incidents.detail', [
            'titre'        => 'Detail incident',
            'id'           => $requete->params['id'] ?? null,
            'peutModifier' => Access::autorise($role, 'incidents', 'edit'),
        ]);
    }
}
