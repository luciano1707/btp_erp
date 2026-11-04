<?php
namespace App\Controllers\Web;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Response;

final class PhotoPageController extends Controller
{
    public function liste(Request $requete): void
    {
        Response::vue('photos.liste', ['titre' => 'Photos']);
    }

    public function detail(Request $requete): void
    {
        Response::vue('photos.detail', ['titre' => 'Détail photo', 'id' => $requete->params['id'] ?? null]);
    }
}