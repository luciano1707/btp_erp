<?php

namespace App\Controllers\Web;

use App\Core\Controller;
use App\Core\Access;
use App\Core\Request;
use App\Core\Response;

/** Pages web des achats & du stock (Phase 5). */
final class AchatPageController extends Controller
{
    /** GET /achats */
    public function liste(Request $requete): void
    {
        $role = $requete->auth['role'] ?? null;
        Response::vue('achats.liste', [
            'titre'     => 'Achats',
            'peutCreer' => Access::autorise($role, 'achats', 'create'),
        ]);
    }

    /** GET /achats/nouveau */
    public function formulaire(Request $requete): void
    {
        Response::vue('achats.formulaire', ['titre' => 'Nouvel achat']);
    }

    /** GET /achats/{id} */
    public function detail(Request $requete): void
    {
        $role = $requete->auth['role'] ?? null;
        Response::vue('achats.detail', [
            'titre'            => 'Detail achat',
            'id'               => (int) $requete->params['id'],
            'peutReceptionner' => Access::autorise($role, 'achats', 'validate'),
            'peutAnnuler'      => Access::autorise($role, 'achats', 'delete'),
        ]);
    }

    /** GET /stock */
    public function stock(Request $requete): void
    {
        $role = $requete->auth['role'] ?? null;
        Response::vue('stock.index', [
            'titre'      => 'Stock',
            'peutEcrire' => Access::autorise($role, 'stock', 'create'),
        ]);
    }
}
