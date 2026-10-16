<?php

namespace App\Core;

/** Matrice RBAC centrale des modules et actions de l'application. */
final class Access
{
    /** @var array<string,array<string,string[]>> */
    private const MATRICE = [
        'tableau_de_bord' => [
            'chef_chantier' => ['view'], 'comptable' => ['view'], 'magasinier' => ['view'],
        ],
        'chantiers' => [
            'chef_chantier' => ['view', 'edit'], 'comptable' => ['view'], 'magasinier' => ['view'],
        ],
        'lots' => [
            'chef_chantier' => ['view', 'create', 'edit', 'delete'],
            'comptable' => ['view'], 'magasinier' => ['view'],
        ],
        'pointages' => [
            'chef_chantier' => ['view', 'edit'],
            'comptable' => ['view'], 'magasinier' => ['view'],
        ],
        'finances' => [
            'comptable' => ['view', 'create', 'edit', 'validate'],
        ],
        'achats' => [
            'chef_chantier' => ['view'], 'comptable' => ['view', 'create', 'edit', 'validate'],
            'magasinier' => ['view', 'create', 'edit', 'validate'],
        ],
        'stock' => [
            'chef_chantier' => ['view'], 'comptable' => ['view'],
            'magasinier' => ['view', 'create', 'edit', 'validate'],
        ],
        'devis' => [
            'chef_chantier' => ['view'], 'comptable' => ['view', 'create', 'edit', 'validate'],
        ],
        'factures' => [
            'comptable' => ['view', 'create', 'edit', 'validate'],
        ],
        'referentiels' => [
            'chef_chantier' => ['view'], 'comptable' => ['view'], 'magasinier' => ['view'],
        ],
        'employes' => [
            'chef_chantier' => ['view'], 'comptable' => ['view'],
            'magasinier' => ['view'],
        ],
        'clients' => [
            'chef_chantier' => ['view'], 'comptable' => ['view', 'edit'],
            'magasinier' => ['view'],
        ],
        'fournisseurs' => [
            'chef_chantier' => ['view'], 'comptable' => ['view', 'edit'],
            'magasinier' => ['view', 'create', 'edit'],
        ],
        'engins' => [
            'chef_chantier' => ['view', 'edit'], 'comptable' => ['view'],
            'magasinier' => ['view', 'edit'],
        ],
        'materiaux' => [
            'chef_chantier' => ['view'], 'comptable' => ['view'],
            'magasinier' => ['view', 'create', 'edit', 'delete'],
        ],
        'journal' => [
            'chef_chantier' => ['view'], 'comptable' => ['view'], 'magasinier' => ['view'],
        ],
        'profil' => [
            'directeur' => ['view', 'edit', 'password'], 'chef_chantier' => ['view', 'edit', 'password'],
            'comptable' => ['view', 'edit', 'password'], 'magasinier' => ['view', 'edit', 'password'],
        ],
        'utilisateurs' => [
            'chef_chantier' => ['view'], 'comptable' => ['view'], 'magasinier' => ['view'],
        ],
        'parametres' => [],
    ];

    public static function autorise(?string $role, string $module, string $action = 'view'): bool
    {
        if ($role === null) {
            return false;
        }
        if ($role === 'directeur') {
            return true;
        }
        return in_array($action, self::MATRICE[$module][$role] ?? [], true);
    }

    /** @return string[] */
    public static function rolesAutorises(string $module, string $action = 'view'): array
    {
        $roles = [];
        foreach (self::MATRICE[$module] ?? [] as $role => $actions) {
            if (in_array($action, $actions, true)) {
                $roles[] = $role;
            }
        }
        return $roles;
    }

    /** @return array<string,array<string,string[]>> */
    public static function matrice(): array
    {
        return self::MATRICE;
    }

    /**
     * Champs exposés et modifiables pour chaque rôle sur les référentiels.
     * Une valeur null signifie que le directeur dispose de tous les champs.
     *
     * @return string[]|null
     */
    public static function champsReferentiel(?string $role, string $module, string $action = 'view'): ?array
    {
        if ($role === 'directeur') {
            return null;
        }

        $politiques = [
            'chantiers' => [
                'chef_chantier' => [
                    'view' => ['id', 'code', 'nom', 'type', 'client_nom', 'responsable_nom', 'localisation', 'date_debut', 'date_fin_prevue', 'date_fin_reelle', 'statut', 'description', 'lots', 'stats'],
                    'edit' => ['responsable_id', 'localisation', 'date_fin_reelle', 'statut', 'description'],
                ],
                'comptable' => ['view' => ['id', 'code', 'nom', 'type', 'client_nom', 'responsable_nom', 'localisation', 'date_debut', 'date_fin_prevue', 'date_fin_reelle', 'budget_previsionnel', 'statut', 'description', 'lots', 'stats']],
                'magasinier' => [
                    'view' => ['id', 'code', 'nom', 'type', 'client_nom', 'responsable_nom', 'localisation', 'date_debut', 'date_fin_prevue', 'statut', 'description', 'lots', 'stats'],
                ],
            ],
            'employes' => [
                'chef_chantier' => ['view' => ['id', 'matricule', 'nom', 'prenom', 'poste', 'actif']],
                'comptable' => ['view' => ['id', 'matricule', 'nom', 'prenom', 'telephone', 'poste', 'type_contrat', 'taux_journalier', 'actif']],
                'magasinier' => ['view' => ['id', 'nom', 'prenom', 'poste', 'actif']],
            ],
            'clients' => [
                'chef_chantier' => ['view' => ['id', 'nom', 'contact', 'telephone', 'email', 'adresse', 'actif']],
                'comptable' => [
                    'view' => ['id', 'nom', 'contact', 'telephone', 'email', 'adresse', 'nif', 'stat', 'actif'],
                    'edit' => ['contact', 'telephone', 'email', 'adresse', 'nif', 'stat'],
                ],
                'magasinier' => ['view' => ['id', 'nom', 'contact']],
            ],
            'fournisseurs' => [
                'chef_chantier' => ['view' => ['id', 'nom', 'categorie', 'contact', 'telephone']],
                'comptable' => [
                    'view' => ['id', 'nom', 'categorie', 'contact', 'telephone', 'email', 'adresse', 'nif', 'stat', 'actif'],
                    'edit' => ['contact', 'telephone', 'email', 'adresse', 'nif', 'stat'],
                ],
                'magasinier' => [
                    'view' => ['id', 'nom', 'categorie', 'contact', 'telephone', 'email', 'adresse', 'actif'],
                    'create' => ['nom', 'categorie', 'contact', 'telephone', 'email', 'adresse', 'actif'],
                    'edit' => ['nom', 'categorie', 'contact', 'telephone', 'email', 'adresse', 'actif'],
                ],
            ],
            'engins' => [
                'chef_chantier' => [
                    'view' => ['id', 'code', 'designation', 'type', 'immatriculation', 'etat', 'actif'],
                    'edit' => ['etat'],
                ],
                'comptable' => ['view' => ['id', 'code', 'designation', 'cout_horaire']],
                'magasinier' => [
                    'view' => ['id', 'code', 'designation', 'type', 'immatriculation', 'etat', 'actif'],
                    'edit' => ['etat', 'actif'],
                ],
            ],
            'materiaux' => [
                'chef_chantier' => ['view' => ['id', 'code', 'designation', 'unite']],
                'comptable' => ['view' => ['id', 'code', 'designation', 'unite', 'prix_unitaire']],
                'magasinier' => [
                    'view' => ['id', 'code', 'designation', 'unite', 'prix_unitaire', 'seuil_alerte', 'actif'],
                    'create' => ['code', 'designation', 'unite', 'prix_unitaire', 'seuil_alerte', 'actif'],
                    'edit' => ['code', 'designation', 'unite', 'prix_unitaire', 'seuil_alerte', 'actif'],
                ],
            ],
        ];

        return $politiques[$module][$role][$action] ?? [];
    }
}
