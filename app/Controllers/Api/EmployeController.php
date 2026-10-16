<?php

namespace App\Controllers\Api;

use App\Core\ResourceController;
use App\Models\Employe;

/** API CRUD des employes. */
final class EmployeController extends ResourceController
{
    protected string $entite = 'employe';
    protected string $modulePermission = 'employes';
    protected array $colonnesRecherche = ['matricule', 'nom', 'prenom', 'poste'];
    protected array $champs = [
        'matricule', 'nom', 'prenom', 'telephone', 'poste', 'type_contrat', 'taux_journalier', 'actif',
    ];
    protected array $reglesCreation = [
        'nom'             => 'requis|longueur_max:100',
        'prenom'          => 'longueur_max:100',
        'type_contrat'    => 'dans:journalier,mensuel,sous_traitant',
        'taux_journalier' => 'entier|min:0',
        'actif'           => 'entier',
    ];

    public function __construct()
    {
        $this->modele = new Employe();
    }
}
