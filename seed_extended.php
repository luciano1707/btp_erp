<?php

/**
 * Script pour ajouter des données supplémentaires de démonstration
 * Usage : php seed_extended.php
 */

require __DIR__ . '/app/Core/Autoloader.php';
App\Core\Autoloader::enregistrer(__DIR__);
App\Core\Env::charger(__DIR__ . '/.env');
require __DIR__ . '/app/Helpers/format.php';

use App\Core\Database;
use App\Models\Budget;
use App\Models\Chantier;
use App\Models\DemandeMateriel;
use App\Models\Depense;
use App\Models\Incident;
use App\Models\Notification;
use App\Models\Qualite;
use App\Models\RapportJournalier;
use App\Models\Rfi;
use App\Models\Securite;

echo "=== Ajout de donnees supplementaires ===\n\n";

$db = Database::connexion();

// Reparer les rapports dont le numero est vide
$db->exec("UPDATE rapports_journaliers SET numero = CONCAT('RJ-', DATE_FORMAT(date_rapport, '%Y%m%d'), '-', LPAD(id, 4, '0')) WHERE numero = '' OR numero IS NULL");

// Vérifier les données existantes
$counts = [
    'chantiers' => $db->query('SELECT COUNT(*) FROM chantiers')->fetchColumn(),
    'budgets' => $db->query('SELECT COUNT(*) FROM budgets')->fetchColumn(),
    'demandes_materiel' => $db->query('SELECT COUNT(*) FROM demandes_materiel')->fetchColumn(),
    'rapports_journaliers' => $db->query('SELECT COUNT(*) FROM rapports_journaliers')->fetchColumn(),
    'depenses' => $db->query('SELECT COUNT(*) FROM depenses')->fetchColumn(),
    'qualite_inspections' => $db->query('SELECT COUNT(*) FROM qualite_inspections')->fetchColumn(),
    'securite_observations' => $db->query('SELECT COUNT(*) FROM securite_observations')->fetchColumn(),
    'incidents' => $db->query('SELECT COUNT(*) FROM incidents')->fetchColumn(),
    'rfi' => $db->query('SELECT COUNT(*) FROM rfi')->fetchColumn(),
    'notifications' => $db->query('SELECT COUNT(*) FROM notifications')->fetchColumn(),
];

echo "Donnees actuelles :\n";
foreach ($counts as $table => $count) {
    echo "  $table: $count\n";
}
echo "\n";

// Obtenir l'ID du chef de chantier pour les créations
$chefId = $db->query("SELECT id FROM utilisateurs WHERE role = 'chef_chantier' LIMIT 1")->fetchColumn();
if (!$chefId) {
    echo "Erreur: aucun chef de chantier trouve.\n";
    exit(1);
}

// Obtenir les IDs des chantiers
$chantierIds = $db->query("SELECT id FROM chantiers ORDER BY id")->fetchAll(PDO::FETCH_COLUMN);
if (empty($chantierIds)) {
    echo "Erreur: aucun chantier trouve.\n";
    exit(1);
}

// === Ajouter des budgets ===
if ($counts['budgets'] == 0) {
    echo "Ajout des budgets...\n";
    $budget = new Budget();
    $annee = date('Y');
    
    foreach ($chantierIds as $i => $chantierId) {
        $budget->creerAvecLignes([
            'chantier_id' => $chantierId,
            'annee' => $annee,
            'budget_previsionnel' => 1000000000 + ($i * 500000000),
            'budget_revision' => 0,
            'devise' => 'MGA',
            'statut' => 'ouvert',
            'notes' => 'Budget initial pour ' . $annee,
            'cree_par' => $chefId,
        ], [
            ['rubrique' => 'Main d\'oeuvre', 'montant_prevu' => 400000000, 'montant_engage' => 150000000, 'montant_reel' => 120000000],
            ['rubrique' => 'Materiaux', 'montant_prevu' => 350000000, 'montant_engage' => 100000000, 'montant_reel' => 80000000],
            ['rubrique' => 'Engins', 'montant_prevu' => 150000000, 'montant_engage' => 50000000, 'montant_reel' => 40000000],
            ['rubrique' => 'Frais divers', 'montant_prevu' => 100000000, 'montant_engage' => 20000000, 'montant_reel' => 15000000],
        ]);
        echo "  Budget cree pour chantier #$chantierId\n";
    }
    echo "Budgets ajoutes avec succes.\n\n";
} else {
    echo "Budgets deja presents, passe.\n\n";
}

// === Ajouter des demandes de matériel ===
if ($counts['demandes_materiel'] < 5) {
    echo "Ajout des demandes de materiel...\n";
    $demande = new DemandeMateriel();
    
    $demandes = [
        ['chantier_id' => $chantierIds[0], 'objet' => 'Ciment pour fondations', 'urgence' => 'urgente', 'statut' => 'valide'],
        ['chantier_id' => $chantierIds[0], 'objet' => 'Fer a beton 12mm', 'urgence' => 'normale', 'statut' => 'en_attente'],
        ['chantier_id' => $chantierIds[1], 'objet' => 'Sable et gravillon', 'urgence' => 'normale', 'statut' => 'traite'],
        ['chantier_id' => $chantierIds[2], 'objet' => 'Parpaings 20', 'urgence' => 'tres_urgente', 'statut' => 'en_attente'],
    ];
    
    foreach ($demandes as $d) {
        $id = $demande->creerAvecLignes([
            'numero' => DemandeMateriel::genererNumero(),
            'chantier_id' => $d['chantier_id'],
            'demandeur_id' => $chefId,
            'objet' => $d['objet'],
            'date_demande' => date('Y-m-d', strtotime('-' . rand(1, 10) . ' days')),
            'urgence' => $d['urgence'],
            'statut' => $d['statut'],
            'notes' => 'Demande pour les travaux en cours',
        ], [
            ['designation' => 'Ciment CEM II 42.5', 'unite' => 'sac', 'quantite_demandee' => 100, 'prix_unitaire' => 38000],
            ['designation' => 'Fer a beton 12mm', 'unite' => 'barre', 'quantite_demandee' => 50, 'prix_unitaire' => 45000],
        ]);
        echo "  Demande #$id: {$d['objet']} ({$d['statut']})\n";
    }
    echo "Demandes de materiel ajoutees avec succes.\n\n";
} else {
    echo "Demandes de materiel deja presentes, passe.\n\n";
}

// === Ajouter des rapports journaliers ===
if ($counts['rapports_journaliers'] < 15) {
    echo "Ajout des rapports journaliers...\n";
    $rapport = new RapportJournalier();
    
    for ($i = 1; $i <= 15; $i++) {
        $date = date('Y-m-d', strtotime("-$i days"));
        $chantierId = $chantierIds[$i % count($chantierIds)];
        
        $meteos = ['ensoleille', 'nuageux', 'pluvieux', 'orageux'];
        $travaux = [
            'Betonnage des fondations - equipe de 4 personnes',
            'Pose des armatures - zone nord',
            'Coulage du dalle RDC - preparation du coffrage',
            'Terrassement preliminaire - engins en cours',
            'Installation des echafaudages - securite verifiee',
        ];
        
        $id = $rapport->creer([
            'numero' => RapportJournalier::genererNumero(),
            'chantier_id' => $chantierId,
            'chef_chantier_id' => $chefId,
            'date_rapport' => $date,
            'meteo' => $meteos[array_rand($meteos)],
            'avancement_pct' => rand(60, 95),
            'travaux_realises' => $travaux[array_rand($travaux)],
            'problemes' => rand(0, 1) ? 'Retard livraison ciment' : null,
            'observations' => 'Travail normal, respect des delais',
            'statut' => 'soumis',
        ]);
        echo "  Rapport #$id: $date (chantier #$chantierId)\n";
    }
    echo "Rapports journaliers ajoutes avec succes.\n\n";
} else {
    echo "Rapports journaliers deja presents, passe.\n\n";
}

// === Ajouter des dépenses ===
if ($counts['depenses'] == 0) {
    echo "Ajout des depenses...\n";
    $depense = new Depense();
    
    $categories = ['transport', 'frais_divers', 'sous_traitance', 'equipement'];
    $descriptions = [
        'Carburant engins - semaine 45',
        'Location grue supplementaire',
        'Paiement sous-traitant electricite',
        'Achat equipements de securite',
        'Frais de deplacement equipe',
        'Fournitures bureau chantier',
    ];
    
    for ($i = 0; $i < 20; $i++) {
        $date = date('Y-m-d', strtotime("-" . rand(1, 30) . " days"));
        $chantierId = $chantierIds[$i % count($chantierIds)];
        
        $id = $depense->creer([
            'numero' => Depense::genererNumero(),
            'chantier_id' => $chantierId,
            'declarant_id' => $chefId,
            'date_depense' => $date,
            'libelle' => $descriptions[array_rand($descriptions)],
            'montant' => (rand(50, 500) * 10000),
            'devise' => 'MGA',
            'categorie' => $categories[array_rand($categories)],
            'statut' => rand(0, 1) ? 'valide' : 'en_attente',
            'valide_par' => rand(0, 1) ? null : $chefId,
            'notes' => 'Depense operationnelle',
        ]);
        echo "  Depense #$id: $date ({$categories[array_rand($categories)]})\n";
    }
    echo "Depenses ajoutees avec succes.\n\n";
} else {
    echo "Depenses deja presentes, passe.\n\n";
}

// IDs utiles pour les modules qualite / securite / incidents / RFI
$directeurId = $db->query("SELECT id FROM utilisateurs WHERE role = 'directeur' LIMIT 1")->fetchColumn() ?: $chefId;
$comptableId = $db->query("SELECT id FROM utilisateurs WHERE role = 'comptable' LIMIT 1")->fetchColumn() ?: $chefId;
$lotsParChantier = [];
foreach ($db->query('SELECT id, chantier_id FROM lots ORDER BY id')->fetchAll(PDO::FETCH_ASSOC) as $lot) {
    $lotsParChantier[(int) $lot['chantier_id']][] = (int) $lot['id'];
}

// === Ajouter des inspections qualite ===
if ($counts['qualite_inspections'] == 0) {
    echo "Ajout des inspections qualite...\n";
    $qualite = new Qualite();

    $inspections = [
        ['resultat' => 'conforme', 'type' => 'Reception fondations', 'constat' => 'Fondations conformes aux plans et au ferraillage prevu.', 'action' => null, 'statut' => 'clos'],
        ['resultat' => 'non_conforme', 'type' => 'Controle ferraillage', 'constat' => 'Enrobage insuffisant sur plusieurs poteaux.', 'action' => 'Reprise de l\'enrobage et controle avant coulage.', 'statut' => 'en_cours'],
        ['resultat' => 'reserve', 'type' => 'Controle beton', 'constat' => 'Resistance apres 7 jours legerement en dessous du seuil.', 'action' => 'Attendre 28 jours et refaire les essais.', 'statut' => 'ouvert'],
        ['resultat' => 'conforme', 'type' => 'Reception gros oeuvre', 'constat' => 'Ecart de verticalite dans les tolerances.', 'action' => null, 'statut' => 'clos'],
        ['resultat' => 'conforme', 'type' => 'Controle revetement', 'constat' => 'Application correcte, aspect homogene.', 'action' => null, 'statut' => 'clos'],
        ['resultat' => 'non_conforme', 'type' => 'Controle etancheite', 'constat' => 'Infiltration constatee en terrasse zone est.', 'action' => 'Reprise de la membrane et nouveau test.', 'statut' => 'en_cours'],
        ['resultat' => 'reserve', 'type' => 'Controle menuiserie', 'constat' => 'Quelques ajustements de fermeture a prevoir.', 'action' => 'Reglage des quincailleries.', 'statut' => 'ouvert'],
        ['resultat' => 'conforme', 'type' => 'Reception provisoire partielle', 'constat' => 'Travaux receptions sans reserve majeure.', 'action' => null, 'statut' => 'clos'],
    ];

    foreach ($inspections as $i => $q) {
        $chantierId = (int) $chantierIds[$i % count($chantierIds)];
        $lotId = null;
        if (!empty($lotsParChantier[$chantierId])) {
            $lotId = $lotsParChantier[$chantierId][array_rand($lotsParChantier[$chantierId])];
        }
        $id = $qualite->creer([
            'numero' => Qualite::genererNumero(),
            'chantier_id' => $chantierId,
            'inspecteur_id' => $i % 2 === 0 ? $chefId : $directeurId,
            'lot_id' => $lotId,
            'date_inspection' => date('Y-m-d', strtotime('-' . rand(1, 45) . ' days')),
            'type_inspection' => $q['type'],
            'resultat' => $q['resultat'],
            'constat' => $q['constat'],
            'action_corrective' => $q['action'],
            'statut' => $q['statut'],
        ]);
        echo "  Inspection qualite #$id: {$q['type']} ({$q['resultat']})\n";
    }
    echo "Inspections qualite ajoutees avec succes.\n\n";
} else {
    echo "Inspections qualite deja presentes, passe.\n\n";
}

// === Ajouter des observations securite ===
if ($counts['securite_observations'] == 0) {
    echo "Ajout des observations securite...\n";
    $securite = new Securite();

    $observations = [
        ['type' => 'danger', 'lieu' => 'Zone de coffrage', 'description' => 'Absence de garde-corps sur une trémie non protegee.', 'action' => 'Zone balisee et condamnee immediatement.', 'mesure' => 'Installer des garde-corps definitifs avant reprise.', 'statut' => 'en_cours'],
        ['type' => 'risque', 'lieu' => 'Depot materiaux', 'description' => 'Stockage de barres de fer sans calage stable.', 'action' => 'Reorganisation du stock et calage.', 'mesure' => 'Controle hebdomadaire du stockage.', 'statut' => 'clos'],
        ['type' => 'bonne_pratique', 'lieu' => 'Equipe maconnerie', 'description' => 'Port complet des EPI constate ce matin.', 'action' => null, 'mesure' => 'Maintenir la sensibilisation quotidienne.', 'statut' => 'clos'],
        ['type' => 'danger', 'lieu' => 'Reseau electrique provisoire', 'description' => 'Cables au sol traversant une zone de passage.', 'action' => 'Cables releves et proteges.', 'mesure' => 'Passage de cables en hauteur.', 'statut' => 'en_cours'],
        ['type' => 'risque', 'lieu' => 'Engin de levage', 'description' => 'Elingue presentant une usure visible.', 'action' => 'Elingue retiree du service.', 'mesure' => 'Inspection mensuelle des accessoires de levage.', 'statut' => 'clos'],
        ['type' => 'autre', 'lieu' => 'Base vie', 'description' => 'Trousse de premiers secours incomplete.', 'action' => 'Reapprovisionnement effectue.', 'mesure' => 'Verification mensuelle de la trousse.', 'statut' => 'clos'],
        ['type' => 'danger', 'lieu' => 'Fouille en excavation', 'description' => 'Parois non talutees sur une profondeur superieure a 1,3 m.', 'action' => 'Travaux arretes dans la zone.', 'mesure' => 'Etaiement ou talutage avant reprise.', 'statut' => 'ouvert'],
        ['type' => 'bonne_pratique', 'lieu' => 'Atelier ferraillage', 'description' => 'Machine de decoupe equipee de sa protection.', 'action' => null, 'mesure' => 'Controle avant chaque prise de poste.', 'statut' => 'clos'],
    ];

    foreach ($observations as $i => $o) {
        $id = $securite->creer([
            'numero' => Securite::genererNumero(),
            'chantier_id' => (int) $chantierIds[$i % count($chantierIds)],
            'declarant_id' => $i % 3 === 0 ? $directeurId : $chefId,
            'date_observation' => date('Y-m-d', strtotime('-' . rand(1, 30) . ' days')),
            'lieu' => $o['lieu'],
            'type_observation' => $o['type'],
            'description' => $o['description'],
            'action_immediate' => $o['action'],
            'mesure_preventive' => $o['mesure'],
            'statut' => $o['statut'],
        ]);
        echo "  Observation securite #$id: {$o['type']} ({$o['statut']})\n";
    }
    echo "Observations securite ajoutees avec succes.\n\n";
} else {
    echo "Observations securite deja presentes, passe.\n\n";
}

// === Ajouter des incidents ===
if ($counts['incidents'] == 0) {
    echo "Ajout des incidents...\n";
    $incident = new Incident();

    $incidents = [
        ['type' => 'presque_accident', 'gravite' => 'faible', 'lieu' => 'Zone de levage', 'description' => 'Chute d\'un petit outil depuis la nacelle sans blessure.', 'victimes' => null, 'secours' => null, 'action' => 'Rappel des consignes de securite.', 'statut' => 'clos'],
        ['type' => 'incident', 'gravite' => 'moyenne', 'lieu' => 'Atelier', 'description' => 'Deterioration d\'une pompe a beton lors du deplacement.', 'victimes' => null, 'secours' => null, 'action' => 'Reparation planifiee et expertise.', 'statut' => 'enquete'],
        ['type' => 'accident', 'gravite' => 'grave', 'lieu' => 'Zone excavation', 'description' => 'Chute avec entorse a la cheville lors de l\'acces a la fouille.', 'victimes' => 'Un ouvrier, entorse legere', 'secours' => 'Prise en charge sur site puis consultation medicale.', 'action' => 'Amenagement d\'un acces securise.', 'statut' => 'enquete'],
        ['type' => 'incident', 'gravite' => 'faible', 'lieu' => 'Depot', 'description' => 'Vol de quelques sacs de ciment dans la nuit.', 'victimes' => null, 'secours' => null, 'action' => 'Renforcement du gardiennage.', 'statut' => 'enquete'],
        ['type' => 'presque_accident', 'gravite' => 'moyenne', 'lieu' => 'Route RN2', 'description' => 'Croisement dangereux entre un camion de chantier et un usager.', 'victimes' => null, 'secours' => null, 'action' => 'Mise en place de panneaux et ralentisseurs temporaires.', 'statut' => 'ouvert'],
        ['type' => 'incident', 'gravite' => 'faible', 'lieu' => 'Bureau de chantier', 'description' => 'Coupure d\'alimentation ayant entraine une perte de donnees locales.', 'victimes' => null, 'secours' => null, 'action' => 'Installation d\'un onduleur.', 'statut' => 'clos'],
    ];

    foreach ($incidents as $i => $inc) {
        $id = $incident->creer([
            'numero' => Incident::genererNumero(),
            'chantier_id' => (int) $chantierIds[$i % count($chantierIds)],
            'declarant_id' => $i % 2 === 0 ? $chefId : $directeurId,
            'date_incident' => date('Y-m-d H:i:s', strtotime('-' . rand(1, 40) . ' days ' . rand(7, 17) . ' hours')),
            'lieu' => $inc['lieu'],
            'type_incident' => $inc['type'],
            'gravite' => $inc['gravite'],
            'victimes' => $inc['victimes'],
            'description' => $inc['description'],
            'premiers_secours' => $inc['secours'],
            'action_corrective' => $inc['action'],
            'statut' => $inc['statut'],
            'suivi_par' => $inc['statut'] === 'ouvert' ? null : $directeurId,
        ]);
        echo "  Incident #$id: {$inc['type']} ({$inc['gravite']})\n";
    }
    echo "Incidents ajoutes avec succes.\n\n";
} else {
    echo "Incidents deja presents, passe.\n\n";
}

// === Ajouter des RFI ===
if ($counts['rfi'] == 0) {
    echo "Ajout des RFI...\n";
    $rfi = new Rfi();

    $rfis = [
        ['objet' => 'Confirmation ferraillage poutre P12', 'question' => 'Le plan structural indique 6HA12 alors que la note de calcul mentionne 8HA12. Merci de confirmer avant coulage.', 'priorite' => 'haute', 'statut' => 'repondu', 'reponse' => 'La note de calcul prevaut : mettre en place 8HA12.'],
        ['objet' => 'Choix du revetement de sol RDC', 'question' => 'Le client souhaite un carrelage grand format. Est-ce compatible avec le delai de livraison prevu ?', 'priorite' => 'normale', 'statut' => 'en_cours', 'reponse' => null],
        ['objet' => 'Traitement de la zone marécageuse', 'question' => 'Faut-il proceder a un remplacement de sol ou a un renforcement par geotextile sur la zone PK14 ?', 'priorite' => 'critique', 'statut' => 'ouvert', 'reponse' => null],
        ['objet' => 'Tolerance de verticalite poteaux', 'question' => 'Quelle tolerance de verticalite appliquer pour les poteaux du niveau 2 ?', 'priorite' => 'basse', 'statut' => 'repondu', 'reponse' => 'Tolerance de 1/500e conformement au CCTP.'],
        ['objet' => 'Amenee electrique provisoire', 'question' => 'Le point de raccordement prevu est-il suffisant pour alimenter la grue et la centrale a beton ?', 'priorite' => 'haute', 'statut' => 'ouvert', 'reponse' => null],
        ['objet' => 'Validation des echantillons de beton', 'question' => 'Les echantillons transmis la semaine derniere ont-ils ete valides par le bureau de controle ?', 'priorite' => 'normale', 'statut' => 'cloture', 'reponse' => 'Echantillons valides le 12 du mois.'],
    ];

    foreach ($rfis as $i => $r) {
        $id = $rfi->creer([
            'numero' => Rfi::genererNumero(),
            'chantier_id' => (int) $chantierIds[$i % count($chantierIds)],
            'emetteur_id' => $i % 2 === 0 ? $chefId : $directeurId,
            'objet' => $r['objet'],
            'question' => $r['question'],
            'priorite' => $r['priorite'],
            'date_limite' => date('Y-m-d', strtotime('+' . rand(2, 20) . ' days')),
            'statut' => $r['statut'],
        ]);
        if ($r['reponse'] !== null) {
            $rfi->repondre($id, $comptableId, $r['reponse']);
        }
        echo "  RFI #$id: {$r['objet']} ({$r['statut']})\n";
    }
    echo "RFI ajoutes avec succes.\n\n";
} else {
    echo "RFI deja presents, passe.\n\n";
}

// === Ajouter des notifications ===
if ($counts['notifications'] == 0) {
    echo "Ajout des notifications...\n";
    $utilisateurs = $db->query('SELECT id, role FROM utilisateurs WHERE actif = 1 ORDER BY id')->fetchAll(PDO::FETCH_ASSOC);

    $modeles = [
        ['type' => 'demande_materiel', 'titre' => 'Nouvelle demande de materiel', 'message' => 'Une demande de materiel attend votre validation.', 'lien' => '/demandes-materiel'],
        ['type' => 'depense', 'titre' => 'Depense a valider', 'message' => 'Une depense est en attente de validation comptable.', 'lien' => '/depenses'],
        ['type' => 'rapport_journalier', 'titre' => 'Rapport journalier soumis', 'message' => 'Un nouveau rapport journalier a ete soumis par le chef de chantier.', 'lien' => '/rapports-journaliers'],
        ['type' => 'qualite', 'titre' => 'Non-conformite qualite', 'message' => 'Une inspection qualite non conforme necessite une action corrective.', 'lien' => '/qualite'],
        ['type' => 'securite', 'titre' => 'Observation securite', 'message' => 'Une nouvelle observation de securite a ete signalee sur un chantier.', 'lien' => '/securite'],
        ['type' => 'incident', 'titre' => 'Incident declare', 'message' => 'Un incident a ete declare et doit etre suivi.', 'lien' => '/incidents'],
        ['type' => 'rfi', 'titre' => 'RFI en attente de reponse', 'message' => 'Un RFI attend une reponse de votre part.', 'lien' => '/rfi'],
        ['type' => 'budget', 'titre' => 'Budget disponible', 'message' => 'Le budget du chantier a ete mis a jour.', 'lien' => '/budgets'],
    ];

    foreach ($utilisateurs as $u) {
        foreach (array_rand($modeles, 3) as $index) {
            $m = $modeles[$index];
            Notification::creer((int) $u['id'], $m['type'], $m['titre'], $m['message'], $m['lien']);
        }
    }
    echo "  Notifications creees pour " . count($utilisateurs) . " utilisateurs\n";
    echo "Notifications ajoutees avec succes.\n\n";
} else {
    echo "Notifications deja presentes, passe.\n\n";
}

// Vérifier les nouvelles données
$newCounts = [
    'budgets' => $db->query('SELECT COUNT(*) FROM budgets')->fetchColumn(),
    'demandes_materiel' => $db->query('SELECT COUNT(*) FROM demandes_materiel')->fetchColumn(),
    'rapports_journaliers' => $db->query('SELECT COUNT(*) FROM rapports_journaliers')->fetchColumn(),
    'depenses' => $db->query('SELECT COUNT(*) FROM depenses')->fetchColumn(),
    'qualite_inspections' => $db->query('SELECT COUNT(*) FROM qualite_inspections')->fetchColumn(),
    'securite_observations' => $db->query('SELECT COUNT(*) FROM securite_observations')->fetchColumn(),
    'incidents' => $db->query('SELECT COUNT(*) FROM incidents')->fetchColumn(),
    'rfi' => $db->query('SELECT COUNT(*) FROM rfi')->fetchColumn(),
    'notifications' => $db->query('SELECT COUNT(*) FROM notifications')->fetchColumn(),
];

echo "=== Donnees apres ajout ===\n";
foreach ($newCounts as $table => $count) {
    $added = $count - $counts[$table];
    echo "  $table: $count (+$added ajoute)\n";
}

echo "\n=== Termine ===\n";
