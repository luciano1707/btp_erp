<?php

namespace App\Controllers\Api;

use App\Core\Controller;
use App\Core\Database;
use App\Core\Request;
use App\Core\Response;

/**
 * API utilisateurs (liste minimale).
 * Utile pour peupler les selecteurs (ex: responsable de chantier).
 * Ne renvoie jamais le mot de passe. La gestion complete des comptes viendra ulterieurement.
 */
final class UtilisateurController extends Controller
{
    /** GET /api/v1/utilisateurs : liste des comptes actifs (champs non sensibles). */
    public function index(Request $requete): void
    {
        $req = Database::connexion()->query(
            "SELECT id, nom, prenom, role,
                    NULLIF(TRIM(CONCAT(COALESCE(prenom,''),' ',COALESCE(nom,''))), '') AS display_name
             FROM utilisateurs WHERE actif = 1 ORDER BY nom, prenom"
        );
        Response::succes($req->fetchAll(), 'Liste des utilisateurs');
    }
}
