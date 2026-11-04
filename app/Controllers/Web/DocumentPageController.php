<?php
namespace App\Controllers\Web;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Response;

final class DocumentPageController extends Controller
{
    public function liste(Request $requete): void
    {
        Response::vue('documents.liste', ['titre' => 'Documents']);
    }

    public function detail(Request $requete): void
    {
        Response::vue('documents.detail', ['titre' => 'Détail document', 'id' => $requete->params['id'] ?? null]);
    }
}