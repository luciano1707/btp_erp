<?php

/**
 * Registre de configuration des referentiels (Phase 2).
 * Source unique qui pilote a la fois :
 *   - les colonnes des tableaux (liste),
 *   - les champs des formulaires (creation / edition),
 *   - l'endpoint API a interroger.
 * Ajouter un referentiel = ajouter une entree ici (+ migration/modele/controleur/route).
 *
 * Types de colonne : texte (defaut), ariary, booleen, badge.
 * Types de champ  : text, number, email, tel, textarea, select, checkbox.
 */

return [
    'employes' => [
        'libelle'         => 'Employe',
        'libelle_pluriel' => 'Employes',
        'endpoint'        => 'api/v1/employes',
        'colonnes' => [
            ['champ' => 'matricule', 'libelle' => 'Matricule'],
            ['champ' => 'nom', 'libelle' => 'Nom'],
            ['champ' => 'prenom', 'libelle' => 'Prenom'],
            ['champ' => 'poste', 'libelle' => 'Poste'],
            ['champ' => 'type_contrat', 'libelle' => 'Contrat', 'type' => 'badge'],
            ['champ' => 'taux_journalier', 'libelle' => 'Taux/jour', 'type' => 'ariary'],
            ['champ' => 'actif', 'libelle' => 'Actif', 'type' => 'booleen'],
        ],
        'champs' => [
            ['champ' => 'matricule', 'libelle' => 'Matricule', 'type' => 'text'],
            ['champ' => 'nom', 'libelle' => 'Nom', 'type' => 'text', 'requis' => true],
            ['champ' => 'prenom', 'libelle' => 'Prenom', 'type' => 'text'],
            ['champ' => 'telephone', 'libelle' => 'Telephone', 'type' => 'tel'],
            ['champ' => 'poste', 'libelle' => 'Poste', 'type' => 'text'],
            ['champ' => 'type_contrat', 'libelle' => 'Type de contrat', 'type' => 'select', 'options' => [
                'journalier' => 'Journalier', 'mensuel' => 'Mensuel', 'sous_traitant' => 'Sous-traitant',
            ]],
            ['champ' => 'taux_journalier', 'libelle' => 'Taux journalier (Ar)', 'type' => 'number'],
            ['champ' => 'actif', 'libelle' => 'Actif', 'type' => 'checkbox', 'defaut' => true],
        ],
    ],

    'clients' => [
        'libelle'         => 'Client',
        'libelle_pluriel' => 'Clients',
        'endpoint'        => 'api/v1/clients',
        'colonnes' => [
            ['champ' => 'nom', 'libelle' => 'Nom / Raison sociale'],
            ['champ' => 'contact', 'libelle' => 'Contact'],
            ['champ' => 'telephone', 'libelle' => 'Telephone'],
            ['champ' => 'nif', 'libelle' => 'NIF'],
            ['champ' => 'actif', 'libelle' => 'Actif', 'type' => 'booleen'],
        ],
        'champs' => [
            ['champ' => 'nom', 'libelle' => 'Nom / Raison sociale', 'type' => 'text', 'requis' => true],
            ['champ' => 'contact', 'libelle' => 'Personne a contacter', 'type' => 'text'],
            ['champ' => 'telephone', 'libelle' => 'Telephone', 'type' => 'tel'],
            ['champ' => 'email', 'libelle' => 'E-mail', 'type' => 'email'],
            ['champ' => 'adresse', 'libelle' => 'Adresse', 'type' => 'textarea'],
            ['champ' => 'nif', 'libelle' => 'NIF (numero fiscal)', 'type' => 'text'],
            ['champ' => 'stat', 'libelle' => 'STAT (numero statistique)', 'type' => 'text'],
            ['champ' => 'actif', 'libelle' => 'Actif', 'type' => 'checkbox', 'defaut' => true],
        ],
    ],

    'fournisseurs' => [
        'libelle'         => 'Fournisseur',
        'libelle_pluriel' => 'Fournisseurs',
        'endpoint'        => 'api/v1/fournisseurs',
        'colonnes' => [
            ['champ' => 'nom', 'libelle' => 'Nom'],
            ['champ' => 'categorie', 'libelle' => 'Categorie', 'type' => 'badge'],
            ['champ' => 'contact', 'libelle' => 'Contact'],
            ['champ' => 'telephone', 'libelle' => 'Telephone'],
            ['champ' => 'actif', 'libelle' => 'Actif', 'type' => 'booleen'],
        ],
        'champs' => [
            ['champ' => 'nom', 'libelle' => 'Nom', 'type' => 'text', 'requis' => true],
            ['champ' => 'categorie', 'libelle' => 'Categorie', 'type' => 'text'],
            ['champ' => 'contact', 'libelle' => 'Personne a contacter', 'type' => 'text'],
            ['champ' => 'telephone', 'libelle' => 'Telephone', 'type' => 'tel'],
            ['champ' => 'email', 'libelle' => 'E-mail', 'type' => 'email'],
            ['champ' => 'adresse', 'libelle' => 'Adresse', 'type' => 'textarea'],
            ['champ' => 'nif', 'libelle' => 'NIF', 'type' => 'text'],
            ['champ' => 'stat', 'libelle' => 'STAT', 'type' => 'text'],
            ['champ' => 'actif', 'libelle' => 'Actif', 'type' => 'checkbox', 'defaut' => true],
        ],
    ],

    'engins' => [
        'libelle'         => 'Engin',
        'libelle_pluriel' => 'Engins',
        'endpoint'        => 'api/v1/engins',
        'colonnes' => [
            ['champ' => 'code', 'libelle' => 'Code'],
            ['champ' => 'designation', 'libelle' => 'Designation'],
            ['champ' => 'type', 'libelle' => 'Type'],
            ['champ' => 'immatriculation', 'libelle' => 'Immatriculation'],
            ['champ' => 'etat', 'libelle' => 'Etat', 'type' => 'badge'],
            ['champ' => 'cout_horaire', 'libelle' => 'Cout/h', 'type' => 'ariary'],
        ],
        'champs' => [
            ['champ' => 'code', 'libelle' => 'Code', 'type' => 'text'],
            ['champ' => 'designation', 'libelle' => 'Designation', 'type' => 'text', 'requis' => true],
            ['champ' => 'type', 'libelle' => 'Type (camion, pelle...)', 'type' => 'text'],
            ['champ' => 'immatriculation', 'libelle' => 'Immatriculation', 'type' => 'text'],
            ['champ' => 'etat', 'libelle' => 'Etat', 'type' => 'select', 'options' => [
                'disponible' => 'Disponible', 'en_service' => 'En service',
                'maintenance' => 'Maintenance', 'hors_service' => 'Hors service',
            ]],
            ['champ' => 'cout_horaire', 'libelle' => 'Cout horaire (Ar)', 'type' => 'number'],
            ['champ' => 'actif', 'libelle' => 'Actif', 'type' => 'checkbox', 'defaut' => true],
        ],
    ],

    'materiaux' => [
        'libelle'         => 'Materiau',
        'libelle_pluriel' => 'Materiaux',
        'endpoint'        => 'api/v1/materiaux',
        'colonnes' => [
            ['champ' => 'code', 'libelle' => 'Code'],
            ['champ' => 'designation', 'libelle' => 'Designation'],
            ['champ' => 'unite', 'libelle' => 'Unite'],
            ['champ' => 'prix_unitaire', 'libelle' => 'Prix unitaire', 'type' => 'ariary'],
            ['champ' => 'actif', 'libelle' => 'Actif', 'type' => 'booleen'],
        ],
        'champs' => [
            ['champ' => 'code', 'libelle' => 'Code', 'type' => 'text'],
            ['champ' => 'designation', 'libelle' => 'Designation', 'type' => 'text', 'requis' => true],
            ['champ' => 'unite', 'libelle' => 'Unite (sac, m3, kg...)', 'type' => 'text'],
            ['champ' => 'prix_unitaire', 'libelle' => 'Prix unitaire (Ar)', 'type' => 'number'],
            ['champ' => 'seuil_alerte', 'libelle' => 'Seuil d\'alerte (stock)', 'type' => 'number'],
            ['champ' => 'actif', 'libelle' => 'Actif', 'type' => 'checkbox', 'defaut' => true],
        ],
    ],
];
