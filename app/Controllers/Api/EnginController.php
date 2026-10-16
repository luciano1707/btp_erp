<?php

namespace App\Controllers\Api;

use App\Core\ResourceController;
use App\Models\Engin;

/** API CRUD des engins. */
final class EnginController extends ResourceController
{
    protected string $entite = 'engin';
    protected string $modulePermission = 'engins';
    protected array $colonnesRecherche = ['code', 'designation', 'type', 'immatriculation'];
    protected array $champs = [
        'code', 'designation', 'type', 'immatriculation', 'etat', 'cout_horaire', 'actif',
    ];
    protected array $reglesCreation = [
        'designation'  => 'requis|longueur_max:150',
        'etat'         => 'dans:disponible,en_service,maintenance,hors_service',
        'cout_horaire' => 'entier|min:0',
        'actif'        => 'entier',
    ];

    public function __construct()
    {
        $this->modele = new Engin();
    }
}
