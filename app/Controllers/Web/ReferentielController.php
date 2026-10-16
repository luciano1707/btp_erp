<?php

namespace App\Controllers\Web;

use App\Core\Controller;
use App\Core\Access;
use App\Core\Request;
use App\Core\Response;

/**
 * Pages web des referentiels (Phase 2).
 * Coquilles HTML pilotees par le registre app/Config/referentiels.php ;
 * les donnees transitent par l'API (JWT) cote navigateur.
 */
final class ReferentielController extends Controller
{
    /** @return array<string,mixed> */
    private function config(): array
    {
        return require dirname(__DIR__, 2) . '/Config/referentiels.php';
    }

    /** Retourne [entite, configEntite] ou affiche une 404. @return array{0:string,1:array<string,mixed>} */
    private function entiteOuErreur(Request $requete): array
    {
        $entite = (string) ($requete->params['entite'] ?? '');
        $config = $this->config();

        if (!isset($config[$entite])) {
            Response::vue('erreurs.404', [], 404);
        }

        return [$entite, $config[$entite]];
    }

    /** GET /referentiels : sommaire des referentiels. */
    public function index(Request $requete): void
    {
        $role = $requete->auth['role'] ?? null;
        $config = array_filter(
            $this->config(),
            static fn (array $conf, string $entite): bool => Access::autorise($role, $entite, 'view'),
            ARRAY_FILTER_USE_BOTH
        );
        Response::vue('referentiels.index', [
            'titre'  => 'Referentiels',
            'config' => $config,
        ]);
    }

    /** GET /referentiels/{entite} : liste. */
    public function liste(Request $requete): void
    {
        [$entite, $conf] = $this->entiteOuErreur($requete);
        $role = $requete->auth['role'] ?? null;
        $this->exigerPermission($role, $entite, 'view');
        $conf = $this->configurerChamps($entite, $conf, $role);
        Response::vue('referentiels.liste', [
            'titre'  => $conf['libelle_pluriel'],
            'entite' => $entite,
            'config' => $conf,
            'peutCreer' => Access::autorise($role, $entite, 'create'),
            'peutModifier' => Access::autorise($role, $entite, 'edit'),
            'peutSupprimer' => Access::autorise($role, $entite, 'delete'),
        ]);
    }

    /** GET /referentiels/{entite}/nouveau et /referentiels/{entite}/{id}/modifier : formulaire. */
    public function formulaire(Request $requete): void
    {
        [$entite, $conf] = $this->entiteOuErreur($requete);
        $id = isset($requete->params['id']) ? (int) $requete->params['id'] : null;
        $role = $requete->auth['role'] ?? null;
        $action = $id === null ? 'create' : 'edit';
        $this->exigerPermission($role, $entite, $action);
        $champsAutorises = Access::champsReferentiel($role, $entite, $action);
        if ($champsAutorises !== null) {
            $conf['champs'] = array_values(array_filter(
                $conf['champs'],
                static fn (array $champ): bool => in_array($champ['champ'], $champsAutorises, true)
            ));
        }
        if ($id !== null) {
            foreach ($conf['champs'] as &$champ) {
                unset($champ['requis']);
            }
            unset($champ);
        }

        Response::vue('referentiels.formulaire', [
            'titre'  => ($id ? 'Modifier ' : 'Nouveau ') . strtolower($conf['libelle']),
            'entite' => $entite,
            'config' => $conf,
            'id'     => $id,
        ]);
    }

    private function exigerPermission(?string $role, string $module, string $action): void
    {
        if (!Access::autorise($role, $module, $action)) {
            Response::vue('erreurs.403', ['module' => $module], 403);
        }
    }

    /** Masque les colonnes du tableau que le rôle ne peut pas consulter. */
    private function configurerChamps(string $entite, array $conf, ?string $role): array
    {
        $champsAutorises = Access::champsReferentiel($role, $entite);
        if ($champsAutorises !== null) {
            $conf['colonnes'] = array_values(array_filter(
                $conf['colonnes'],
                static fn (array $colonne): bool => in_array($colonne['champ'], $champsAutorises, true)
            ));
        }
        return $conf;
    }
}
