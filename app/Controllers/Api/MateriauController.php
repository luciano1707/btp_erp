<?php

namespace App\Controllers\Api;

use App\Core\ResourceController;
use App\Models\Materiau;

/** API CRUD des materiaux (catalogue). */
final class MateriauController extends ResourceController
{
    protected string $entite = 'materiau';
    protected string $modulePermission = 'materiaux';
    protected array $colonnesRecherche = ['code', 'designation', 'unite'];
    protected array $champs = [
        'code', 'designation', 'unite', 'prix_unitaire', 'seuil_alerte', 'actif',
    ];
    protected array $reglesCreation = [
        'designation'   => 'requis|longueur_max:150',
        'unite'         => 'longueur_max:20',
        'prix_unitaire' => 'entier|min:0',
        'seuil_alerte'  => 'entier|min:0',
        'actif'         => 'entier',
    ];

    public function __construct()
    {
        $this->modele = new Materiau();
    }
}
