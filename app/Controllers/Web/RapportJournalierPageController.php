<?php

namespace App\Controllers\Web;

use App\Core\Controller;
use App\Core\Access;

use App\Core\Request;
use App\Core\Response;

final class RapportJournalierPageController extends Controller
{
    public function liste(Request $requete): void
    {
        $role = $requete->auth['role'] ?? null;
        Response::vue('rapports_journaliers.liste', [
            'titre'       => 'Rapports journaliers',
            'peutCreer'   => Access::autorise($role, 'rapports_journaliers', 'create'),
            'peutModifier'=> Access::autorise($role, 'rapports_journaliers', 'edit'),
        ]);
    }

    public function formulaire(Request $requete): void
    {
        $id = isset($requete->params['id']) ? (int) $requete->params['id'] : null;
        Response::vue('rapports_journaliers.formulaire', [
            'titre' => $id ? 'Modifier le rapport journalier' : 'Nouveau rapport journalier',
            'id'    => $id,
        ]);
    }

    public function detail(Request $requete): void
    {
        $role = $requete->auth['role'] ?? null;
        Response::vue('rapports_journaliers.detail', [
            'titre'        => 'Détail rapport journalier',
            'id'           => $requete->params['id'] ?? null,
            'peutModifier' => Access::autorise($role, 'rapports_journaliers', 'edit'),
        ]);
    }
}
