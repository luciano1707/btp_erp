<?php

namespace App\Controllers\Web;

use App\Core\Controller;
use App\Core\Access;

use App\Core\Request;
use App\Core\Response;

final class DemandeMaterielPageController extends Controller
{
    /** GET /demandes-materiel */
    public function liste(Request $requete): void
    {
        $role = $requete->auth['role'] ?? null;
        Response::vue('demandes_materiel.liste', [
            'titre'       => 'Demandes de matériel',
            'peutCreer'   => Access::autorise($role, 'demandes_materiel', 'create'),
            'peutModifier'=> Access::autorise($role, 'demandes_materiel', 'edit'),
        ]);
    }

    /** GET /demandes-materiel/nouveau et /demandes-materiel/{id}/modifier */
    public function formulaire(Request $requete): void
    {
        $id = isset($requete->params['id']) ? (int) $requete->params['id'] : null;
        Response::vue('demandes_materiel.formulaire', [
            'titre' => $id ? 'Modifier la demande de matériel' : 'Nouvelle demande de matériel',
            'id'    => $id,
        ]);
    }

    /** GET /demandes-materiel/{id} */
    public function detail(Request $requete): void
    {
        $role = $requete->auth['role'] ?? null;
        Response::vue('demandes_materiel.detail', [
            'titre'       => 'Détail demande de matériel',
            'id'          => $requete->params['id'] ?? null,
            'peutValider' => $role === 'directeur',
            'peutTraiter' => Access::autorise($role, 'demandes_materiel', 'validate'),
            'peutModifier'=> Access::autorise($role, 'demandes_materiel', 'edit'),
        ]);
    }
}
