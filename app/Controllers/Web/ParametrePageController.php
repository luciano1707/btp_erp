<?php

namespace App\Controllers\Web;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Response;

/** Page des parametres de l'entreprise. */
final class ParametrePageController extends Controller
{
    public function index(Request $requete): void
    {
        Response::vue('parametres', ['titre' => 'Parametres']);
    }
}
