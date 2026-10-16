<?php

namespace App\Controllers\Web;

use App\Core\Controller;
use App\Core\Access;
use App\Core\Request;
use App\Core\Response;

/**
 * Pages web des chantiers (Phase 3).
 * Coquilles HTML ; les donnees transitent par l'API (JWT) cote navigateur.
 */
final class ChantierPageController extends Controller
{
    /** Options statiques partagees avec les formulaires. */
    public const TYPES = [
        'batiment' => 'Batiment',
        'route'    => 'Route / travaux publics',
        'autre'    => 'Autre',
    ];

    public const STATUTS = [
        'planifie'  => 'Planifie',
        'en_cours'  => 'En cours',
        'suspendu'  => 'Suspendu',
        'termine'   => 'Termine',
        'annule'    => 'Annule',
    ];

    /** GET /chantiers */
    public function liste(Request $requete): void
    {
        $role = $requete->auth['role'] ?? null;
        Response::vue('chantiers.liste', [
            'titre'              => 'Chantiers',
            'statuts'            => self::STATUTS,
            'peutCreer'          => Access::autorise($role, 'chantiers', 'create'),
            'peutModifier'       => Access::autorise($role, 'chantiers', 'edit'),
            'peutVoirFinances'   => Access::autorise($role, 'finances', 'view'),
        ]);
    }

    /** GET /chantiers/nouveau et /chantiers/{id}/modifier */
    public function formulaire(Request $requete): void
    {
        $id = isset($requete->params['id']) ? (int) $requete->params['id'] : null;
        $role = $requete->auth['role'] ?? null;
        $champsAutorises = Access::champsReferentiel(
            $role,
            'chantiers',
            $id === null ? 'create' : 'edit'
        );
        $statuts = self::STATUTS;
        if ($role === 'chef_chantier' && $id !== null) {
            unset($statuts['termine'], $statuts['annule']);
        }
        Response::vue('chantiers.formulaire', [
            'titre'   => ($id ? 'Modifier le chantier' : 'Nouveau chantier'),
            'id'      => $id,
            'types'   => self::TYPES,
            'statuts' => $statuts,
            'champsAutorises' => $champsAutorises ?? [
                'code', 'nom', 'type', 'client_id', 'responsable_id', 'localisation',
                'date_debut', 'date_fin_prevue', 'date_fin_reelle', 'budget_previsionnel',
                'statut', 'description',
            ],
        ]);
    }

    /** GET /chantiers/{id} */
    public function detail(Request $requete): void
    {
        $role = $requete->auth['role'] ?? null;
        $peutGererLots = Access::autorise($requete->auth['role'] ?? null, 'lots', 'edit');
        Response::vue('chantiers.detail', [
            'titre'          => 'Detail du chantier',
            'id'             => (int) $requete->params['id'],
            'peutGererLots'  => $peutGererLots,
            'peutVoirFinances' => Access::autorise($role, 'finances', 'view'),
            'peutSupprimerChantier' => Access::autorise($role, 'chantiers', 'delete'),
        ]);
    }

    /** GET /chantiers/{id}/pointage */
    public function pointage(Request $requete): void
    {
        $role = $requete->auth['role'] ?? null;
        $peutModifier = Access::autorise($role, 'pointages', 'edit');
        Response::vue('chantiers.pointage', [
            'titre'        => 'Feuille de pointage',
            'id'           => (int) $requete->params['id'],
            'peutModifier' => $peutModifier,
            'peutVoirCout' => in_array($role, ['directeur', 'comptable'], true),
        ]);
    }
}
