<?php

namespace App\Controllers\Api;

use App\Core\Controller;
use App\Core\Database;
use App\Core\Request;
use App\Core\Response;
use PDO;

/**
 * API de consultation du journal d'audit (Phase 8).
 * Reservee au directeur (traçabilite de chaque action).
 */
final class JournalController extends Controller
{
    /** GET /api/v1/journal?page=&limite=&action=&entite= */
    public function index(Request $requete): void
    {
        $db = Database::connexion();
        $limite   = max(1, min((int) $requete->query('limite', 50), 200));
        $page     = max(1, (int) $requete->query('page', 1));
        $decalage = ($page - 1) * $limite;

        $conditions = [];
        $params = [];
        if (($requete->auth['role'] ?? null) !== 'directeur') {
            $conditions[] = 'j.utilisateur_id = :utilisateur_id';
            $params[':utilisateur_id'] = (int) ($requete->auth['sub'] ?? 0);
        }
        if ($requete->query('action')) {
            $conditions[] = 'j.action LIKE :action';
            $params[':action'] = '%' . $requete->query('action') . '%';
        }
        if ($requete->query('entite')) {
            $conditions[] = 'j.entite = :entite';
            $params[':entite'] = $requete->query('entite');
        }
        $recherche = trim((string) $requete->query('recherche', ''));
        if ($recherche !== '') {
            // PDO n'accepte pas qu'un meme parametre nomme apparaisse plusieurs fois.
            $conditions[] = '(j.action LIKE :recherche1 OR j.entite LIKE :recherche2'
                . " OR NULLIF(TRIM(CONCAT(COALESCE(u.prenom,''),' ',COALESCE(u.nom,''))), '') LIKE :recherche3"
                . ' OR CAST(j.entite_id AS CHAR) = :recherche4)';
            $params[':recherche1'] = '%' . $recherche . '%';
            $params[':recherche2'] = '%' . $recherche . '%';
            $params[':recherche3'] = '%' . $recherche . '%';
            $params[':recherche4'] = $recherche;
        }
        $where = $conditions !== [] ? 'WHERE ' . implode(' AND ', $conditions) : '';
        $jointure = 'LEFT JOIN utilisateurs u ON u.id = j.utilisateur_id';

        $reqTotal = $db->prepare("SELECT COUNT(*) FROM journal_audit j $jointure $where");
        $reqTotal->execute($params);
        $total = (int) $reqTotal->fetchColumn();

        $sql = "SELECT j.*, NULLIF(TRIM(CONCAT(COALESCE(u.prenom,''),' ',COALESCE(u.nom,''))), '') AS utilisateur_nom
                FROM journal_audit j
                $jointure
                $where
                ORDER BY j.id DESC LIMIT :limite OFFSET :decalage";
        $req = $db->prepare($sql);
        foreach ($params as $ph => $v) {
            $req->bindValue($ph, $v);
        }
        $req->bindValue(':limite', $limite, PDO::PARAM_INT);
        $req->bindValue(':decalage', $decalage, PDO::PARAM_INT);
        $req->execute();

        Response::succes([
            'elements' => $req->fetchAll(),
            'total'    => $total,
            'page'     => $page,
            'limite'   => $limite,
        ], 'Journal d\'audit');
    }

    /** GET /api/v1/journal/{id} : detail d'une entree d'audit. */
    public function show(Request $requete): void
    {
        $db = Database::connexion();
        $req = $db->prepare(
            'SELECT j.*, NULLIF(TRIM(CONCAT(COALESCE(u.prenom,\'\'),\' \',COALESCE(u.nom,\'\'))), \'\') AS utilisateur_nom
             FROM journal_audit j
             LEFT JOIN utilisateurs u ON u.id = j.utilisateur_id
             WHERE j.id = :id'
        );
        $req->execute([':id' => (int) $requete->params['id']]);
        $ligne = $req->fetch();

        if ($ligne === false) {
            Response::erreur('Entree de journal introuvable.', 404);
        }
        Response::succes($ligne);
    }
}
