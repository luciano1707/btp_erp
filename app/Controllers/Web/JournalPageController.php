<?php

namespace App\Controllers\Web;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Response;

/** Page de consultation du journal d'audit (Phase 8, directeur). */
final class JournalPageController extends Controller
{
    public function index(Request $requete): void
    {
        Response::vue('journal', ['titre' => 'Journal d\'audit']);
    }
}
