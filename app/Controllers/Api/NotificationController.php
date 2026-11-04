<?php

namespace App\Controllers\Api;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Response;
use App\Models\Notification as NotificationModele;

final class NotificationController extends Controller
{
    /** GET /api/v1/notifications */
    public function index(Request $requete): void
    {
        $uid = $this->uid($requete);
        if ($uid === null) {
            Response::erreur('Utilisateur non authentifie.', 401);
        }

        $modele = new NotificationModele();
        $nonLuesSeulement = (string) $requete->query('non_lues', '') === '1';
        $limite = max(1, min(200, (int) $requete->query('limite', 100)));

        Response::succes([
            'elements' => $modele->listePour($uid, $nonLuesSeulement, $limite),
            'non_lues' => $modele->compterNonLues($uid),
        ], 'Notifications');
    }

    /** POST /api/v1/notifications/{id}/lue */
    public function marquerLue(Request $requete): void
    {
        $uid = $this->uid($requete);
        if ($uid === null) {
            Response::erreur('Utilisateur non authentifie.', 401);
        }

        $id = (int) $requete->params['id'];
        $modele = new NotificationModele();
        $modele->marquerLue($id, $uid);

        Response::succes([
            'non_lues' => $modele->compterNonLues($uid),
        ], 'Notification marquee comme lue.');
    }

    /** POST /api/v1/notifications/tout-lire */
    public function toutLire(Request $requete): void
    {
        $uid = $this->uid($requete);
        if ($uid === null) {
            Response::erreur('Utilisateur non authentifie.', 401);
        }

        $nombre = (new NotificationModele())->toutLire($uid);
        Response::succes(['marquees' => $nombre, 'non_lues' => 0], 'Notifications marquees comme lues.');
    }

    private function uid(Request $requete): ?int
    {
        return isset($requete->auth['sub']) ? (int) $requete->auth['sub'] : null;
    }
}
