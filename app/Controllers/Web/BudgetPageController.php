<?php

namespace App\Controllers\Web;

use App\Core\Access;
use App\Core\Controller;
use App\Core\Request;
use App\Core\Response;

final class BudgetPageController extends Controller
{
    public function liste(Request $requete): void
    {
        $role = $requete->auth['role'] ?? null;
        Response::vue('budgets.liste', [
            'titre'     => 'Budgets',
            'peutCreer' => Access::autorise($role, 'budgets', 'edit'),
        ]);
    }

    public function formulaire(Request $requete): void
    {
        $id = isset($requete->params['id']) ? (int) $requete->params['id'] : null;
        Response::vue('budgets.formulaire', [
            'titre' => $id ? 'Modifier le budget' : 'Nouveau budget',
            'id'    => $id,
        ]);
    }

    public function detail(Request $requete): void
    {
        $role = $requete->auth['role'] ?? null;
        Response::vue('budgets.detail', [
            'titre'        => 'Detail budget',
            'id'           => $requete->params['id'] ?? null,
            'peutModifier' => Access::autorise($role, 'budgets', 'edit'),
        ]);
    }
}
