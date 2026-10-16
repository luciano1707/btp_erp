<?php

namespace App\Controllers\Web;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Response;

/** Page du profil personnel, accessible a tous les roles. */
final class ProfilPageController extends Controller
{
    public function index(Request $requete): void
    {
        Response::vue('profil', ['titre' => 'Mon profil']);
    }
}
