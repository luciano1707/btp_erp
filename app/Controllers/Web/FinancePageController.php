<?php

namespace App\Controllers\Web;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Response;

/** Page de suivi financier (Phase 7). */
final class FinancePageController extends Controller
{
    public function index(Request $requete): void
    {
        Response::vue('finances', ['titre' => 'Suivi financier']);
    }
}
