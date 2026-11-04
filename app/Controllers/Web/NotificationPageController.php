<?php

namespace App\Controllers\Web;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Response;

final class NotificationPageController extends Controller
{
    public function index(Request $requete): void
    {
        Response::vue('notifications.index', ['titre' => 'Notifications']);
    }
}
