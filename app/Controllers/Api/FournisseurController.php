<?php

namespace App\Controllers\Api;

use App\Core\ResourceController;
use App\Models\Fournisseur;

/** API CRUD des fournisseurs. */
final class FournisseurController extends ResourceController
{
    protected string $entite = 'fournisseur';
    protected string $modulePermission = 'fournisseurs';
    protected array $colonnesRecherche = ['nom', 'contact', 'categorie', 'nif'];
    protected array $champs = [
        'nom', 'contact', 'telephone', 'email', 'adresse', 'categorie', 'nif', 'stat', 'actif',
    ];
    protected array $reglesCreation = [
        'nom'   => 'requis|longueur_max:150',
        'email' => 'email',
        'actif' => 'entier',
    ];

    public function __construct()
    {
        $this->modele = new Fournisseur();
    }
}
