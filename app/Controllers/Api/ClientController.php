<?php

namespace App\Controllers\Api;

use App\Core\ResourceController;
use App\Models\Client;

/** API CRUD des clients. */
final class ClientController extends ResourceController
{
    protected string $entite = 'client';
    protected string $modulePermission = 'clients';
    protected array $colonnesRecherche = ['nom', 'contact', 'telephone', 'nif'];
    protected array $champs = [
        'nom', 'contact', 'telephone', 'email', 'adresse', 'nif', 'stat', 'actif',
    ];
    protected array $reglesCreation = [
        'nom'   => 'requis|longueur_max:150',
        'email' => 'email',
        'actif' => 'entier',
    ];

    public function __construct()
    {
        $this->modele = new Client();
    }
}
