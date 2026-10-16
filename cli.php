<?php

/**
 * Console d'administration (a executer en ligne de commande).
 *
 * Utilisation :
 *   php cli.php migrate                                  Applique les migrations SQL en attente
 *   php cli.php seed                                     Cree un compte directeur de demonstration
 *   php cli.php creer-admin <email> <nom> <mdp> [role]   Cree un utilisateur (role par defaut : directeur)
 *   php cli.php purger-tokens                            Supprime les refresh tokens expires/revoques
 *
 * Sur Simafri, ces commandes peuvent etre declenchees via un cron cPanel.
 */

declare(strict_types=1);

use App\Core\Audit;
use App\Core\Autoloader;
use App\Core\Database;
use App\Core\Env;
use App\Core\Migrator;
use App\Models\Achat;
use App\Models\Chantier;
use App\Models\Client;
use App\Models\Devis;
use App\Models\Employe;
use App\Models\Facture;
use App\Models\Fournisseur;
use App\Models\Lot;
use App\Models\Materiau;
use App\Models\MouvementStock;
use App\Models\Paiement;
use App\Models\Pointage;
use App\Models\RefreshToken;
use App\Models\Utilisateur;

if (PHP_SAPI !== 'cli') {
    http_response_code(403);
    exit("Ce script doit etre execute en ligne de commande.\n");
}

$racine = __DIR__;

require $racine . '/app/Core/Autoloader.php';
Autoloader::enregistrer($racine);
Env::charger($racine . '/.env');
require $racine . '/app/Helpers/format.php';

$commande = $argv[1] ?? 'help';

switch ($commande) {
    case 'migrate':
        echo "== Migrations ==\n";
        (new Migrator($racine))->migrer();
        echo "Termine.\n";
        break;

    case 'seed':
        seedDirecteur();
        break;

    case 'demo':
        seedDemo();
        break;

    case 'creer-admin':
        creerAdmin(array_slice($argv, 2));
        break;

    case 'reset-mdp':
        reinitialiserMotDePasse(array_slice($argv, 2));
        break;

    case 'purger-tokens':
        $n = (new RefreshToken())->purger();
        echo "$n refresh token(s) purge(s).\n";
        break;

    case 'relances':
        relancesFactures();
        break;

    case 'sauvegarde':
        sauvegarde($racine);
        break;

    default:
        echo "Commandes disponibles :\n";
        echo "  php cli.php migrate                                Applique les migrations SQL\n";
        echo "  php cli.php seed                                   Compte directeur de demonstration\n";
        echo "  php cli.php demo                                   Jeu de donnees de demonstration (6 mois)\n";
        echo "  php cli.php creer-admin <email> <nom> <mdp> [role] Cree un utilisateur\n";
        echo "  php cli.php reset-mdp <email> <nouveau_mdp>        Reinitialise un mot de passe (anti-lockout)\n";
        echo "  php cli.php purger-tokens                          Purge les refresh tokens obsoletes\n";
        echo "  php cli.php relances                               Relance les factures echues (cron)\n";
        echo "  php cli.php sauvegarde                             Sauvegarde MySQL vers storage/backups (cron)\n";
        break;
}

/**
 * Identifie les factures echues et non soldees, et enregistre une relance dans le journal d'audit.
 * (A brancher sur un cron cPanel. L'envoi d'e-mail peut etre ajoute via mail() selon Simafri.)
 */
function relancesFactures(): void
{
    $sql = "SELECT f.id, f.reference, f.echeance, f.montant_ttc, f.montant_paye, c.nom AS client, c.email
            FROM factures f LEFT JOIN clients c ON c.id = f.client_id
            WHERE f.statut IN ('emise','payee_partiel') AND f.echeance IS NOT NULL AND f.echeance < CURDATE()";
    $lignes = Database::connexion()->query($sql)->fetchAll();

    if ($lignes === []) {
        echo "Aucune facture echue.\n";
        return;
    }

    foreach ($lignes as $f) {
        $reste = (int) $f['montant_ttc'] - (int) $f['montant_paye'];
        echo sprintf("  Relance : %s (%s) - reste %s Ar - echeance %s\n",
            $f['reference'] ?? ('#' . $f['id']), $f['client'] ?? 'client inconnu',
            number_format($reste, 0, ',', ' '), $f['echeance']);
        Audit::enregistrer('facture.relance', 'facture', (int) $f['id'], ['reste' => $reste, 'echeance' => $f['echeance']]);
    }
    echo count($lignes) . " facture(s) echue(s) relancee(s).\n";
}

/**
 * Sauvegarde la base de donnees via mysqldump vers storage/backups.
 * A planifier via cron cPanel (ex: quotidien).
 */
function sauvegarde(string $racine): void
{
    $dossier = $racine . '/storage/backups';
    if (!is_dir($dossier)) {
        @mkdir($dossier, 0775, true);
    }

    $base = (string) Env::get('DB_NAME', 'btp_erp');
    $fichier = $dossier . '/backup-' . $base . '-' . date('Ymd-His') . '.sql';

    // mysqldump doit etre dans le PATH (cas Simafri) ; en local XAMPP on peut prefixer le chemin.
    $commande = sprintf(
        'mysqldump --host=%s --port=%s --user=%s %s %s > %s 2>&1',
        escapeshellarg((string) Env::get('DB_HOST', '127.0.0.1')),
        escapeshellarg((string) Env::get('DB_PORT', '3306')),
        escapeshellarg((string) Env::get('DB_USER', 'root')),
        Env::get('DB_PASS', '') !== '' ? '--password=' . escapeshellarg((string) Env::get('DB_PASS', '')) : '',
        escapeshellarg($base),
        escapeshellarg($fichier)
    );

    exec($commande, $sortie, $code);
    if ($code === 0 && is_file($fichier) && filesize($fichier) > 0) {
        echo 'Sauvegarde creee : ' . $fichier . ' (' . round(filesize($fichier) / 1024, 1) . " Ko)\n";
    } else {
        echo "Echec de la sauvegarde (mysqldump introuvable ou erreur). Code $code.\n";
    }
}

/**
 * Cree un compte directeur de demonstration (mot de passe provisoire a changer).
 */
function seedDirecteur(): void
{
    $modele = new Utilisateur();
    $email = 'directeur@digitalchantier.mg';

    if ($modele->trouverParEmail($email) !== null) {
        echo "Le compte de demonstration existe deja ($email).\n";
        return;
    }

    $motDePasse = 'Directeur@2026';
    $modele->creer([
        'nom'              => 'Directeur',
        'prenom'           => 'Demo',
        'email'            => $email,
        'mot_de_passe'     => password_hash($motDePasse, PASSWORD_DEFAULT),
        'role'             => 'directeur',
        'actif'            => 1,
        'doit_changer_mdp' => 1,
    ]);

    echo "Compte de demonstration cree :\n";
    echo "  Email       : $email\n";
    echo "  Mot de passe: $motDePasse  (a changer a la premiere connexion)\n";
}

/**
 * Reinitialise le mot de passe d'un utilisateur existant (utilitaire anti-lockout).
 *
 * @param string[] $args [email, nouveau_mdp]
 */
function reinitialiserMotDePasse(array $args): void
{
    if (count($args) < 2) {
        echo "Usage : php cli.php reset-mdp <email> <nouveau_mot_de_passe>\n";
        return;
    }
    [$email, $motDePasse] = $args;
    if (strlen($motDePasse) < 8) {
        echo "Erreur : le mot de passe doit contenir au moins 8 caracteres.\n";
        return;
    }

    $modele = new Utilisateur();
    $utilisateur = $modele->trouverParEmail($email);
    if ($utilisateur === null) {
        echo "Erreur : aucun compte avec cet email.\n";
        return;
    }

    $modele->definirMotDePasse((int) $utilisateur['id'], password_hash($motDePasse, PASSWORD_DEFAULT));
    echo "Mot de passe reinitialise pour $email.\n";
}

/**
 * Charge un jeu de donnees de demonstration realiste, reparti sur les 6 derniers mois
 * (chantiers, referentiels, achats, pointages, factures + paiements) pour que le
 * tableau de bord soit immediatement parlant. Idempotent (drapeau parametres.demo_charge).
 */
function seedDemo(): void
{
    $db = Database::connexion();
    if ((int) $db->query("SELECT COUNT(*) FROM parametres WHERE cle = 'demo_charge'")->fetchColumn() > 0) {
        echo "Donnees de demonstration deja presentes (rien a faire).\n";
        return;
    }

    // --- Utilisateurs (chef de chantier, comptable, magasinier) ---
    $chef = ensureUtilisateur('hery.chef@digitalchantier.mg', 'Rakotoarisoa', 'Hery', 'chef_chantier');
    ensureUtilisateur('naina.compta@digitalchantier.mg', 'Randria', 'Naina', 'comptable');
    ensureUtilisateur('paul.magasin@digitalchantier.mg', 'Randrianja', 'Paul', 'magasinier');

    // --- Clients ---
    $client = new Client();
    $cId = [];
    foreach ([
        ['nom' => 'Commune Urbaine de Mahajanga', 'contact' => 'Service technique', 'telephone' => '032 11 222 33', 'nif' => '4000123450'],
        ['nom' => 'IMMOBILIER Boeny SARL', 'contact' => 'Rivo A.', 'telephone' => '034 05 678 90', 'nif' => '4000987651'],
        ['nom' => 'Ministere des Travaux Publics', 'contact' => 'Direction regionale', 'telephone' => '020 62 000 00', 'nif' => '4000000012'],
        ['nom' => 'Galaxy Andraharo SA', 'contact' => 'M. Ralaivao', 'telephone' => '033 12 345 67', 'nif' => '4000543219'],
    ] as $c) {
        $cId[] = $client->creer($c + ['actif' => 1]);
    }

    // --- Fournisseurs ---
    $four = new Fournisseur();
    $fId = [];
    foreach ([
        ['nom' => 'Quincaillerie Mahajanga', 'categorie' => 'materiaux', 'telephone' => '032 00 111 22'],
        ['nom' => 'Ciments de Madagascar', 'categorie' => 'materiaux', 'telephone' => '020 22 333 44'],
        ['nom' => 'Location Engins Boeny', 'categorie' => 'location engins', 'telephone' => '034 55 666 77'],
    ] as $f) {
        $fId[] = $four->creer($f + ['actif' => 1]);
    }

    // --- Employes ---
    $emp = new Employe();
    $eId = [];
    foreach ([
        ['matricule' => 'M001', 'nom' => 'Rabe', 'prenom' => 'Jean', 'poste' => "Chef d'equipe", 'type_contrat' => 'mensuel', 'taux_journalier' => 40000],
        ['matricule' => 'M002', 'nom' => 'Rakoto', 'prenom' => 'Paul', 'poste' => 'Macon', 'type_contrat' => 'journalier', 'taux_journalier' => 25000],
        ['matricule' => 'M003', 'nom' => 'Randria', 'prenom' => 'Koto', 'poste' => 'Manoeuvre', 'type_contrat' => 'journalier', 'taux_journalier' => 18000],
        ['matricule' => 'M004', 'nom' => 'Bema', 'prenom' => 'Soa', 'poste' => 'Ferrailleur', 'type_contrat' => 'journalier', 'taux_journalier' => 22000],
        ['matricule' => 'M005', 'nom' => 'Rasoa', 'prenom' => 'Naina', 'poste' => 'Chauffeur', 'type_contrat' => 'mensuel', 'taux_journalier' => 30000],
        ['matricule' => 'M006', 'nom' => 'Tiana', 'prenom' => 'Fara', 'poste' => 'Manoeuvre', 'type_contrat' => 'journalier', 'taux_journalier' => 18000],
    ] as $e) {
        $eId[] = $emp->creer($e + ['actif' => 1]);
    }

    // --- Materiaux + stock initial (certains sous le seuil pour generer des alertes) ---
    $mat = new Materiau();
    $mv = new MouvementStock();
    $mId = [];
    $dateStockInit = date('Y-m-d', strtotime('-2 month'));
    foreach ([
        ['code' => 'CIM01', 'designation' => 'Ciment CEM II 42.5', 'unite' => 'sac', 'prix_unitaire' => 38000, 'seuil_alerte' => 100, 'stock' => 60],
        ['code' => 'FER12', 'designation' => 'Fer a beton 12mm', 'unite' => 'barre', 'prix_unitaire' => 45000, 'seuil_alerte' => 50, 'stock' => 220],
        ['code' => 'SAB01', 'designation' => 'Sable', 'unite' => 'm3', 'prix_unitaire' => 60000, 'seuil_alerte' => 20, 'stock' => 35],
        ['code' => 'GRV01', 'designation' => 'Gravillon', 'unite' => 'm3', 'prix_unitaire' => 80000, 'seuil_alerte' => 20, 'stock' => 12],
        ['code' => 'PAR01', 'designation' => 'Parpaing 20', 'unite' => 'unite', 'prix_unitaire' => 2500, 'seuil_alerte' => 500, 'stock' => 4000],
        ['code' => 'GAS01', 'designation' => 'Gasoil', 'unite' => 'litre', 'prix_unitaire' => 5200, 'seuil_alerte' => 200, 'stock' => 800],
    ] as $m) {
        $stock = $m['stock'];
        unset($m['stock']);
        $id = $mat->creer($m + ['actif' => 1]);
        $mId[] = $id;
        $mv->enregistrer(['materiau_id' => $id, 'type' => 'entree', 'quantite' => $stock, 'motif' => 'Stock initial', 'date_mouvement' => $dateStockInit]);
    }

    // --- Chantiers + lots ---
    $ch = new Chantier();
    $lot = new Lot();
    $chId = [];
    $chantiers = [
        ['code' => 'CH-2026-001', 'nom' => 'Immeuble Galaxy Andraharo', 'type' => 'batiment', 'client' => 3, 'budget' => 2400000000, 'statut' => 'en_cours', 'loc' => 'Andraharo', 'lots' => [['Fondations', 600000000, 100, 'termine'], ['Gros oeuvre', 1000000000, 70, 'en_cours'], ['Second oeuvre', 800000000, 20, 'en_cours']]],
        ['code' => 'CH-2026-002', 'nom' => 'Rehabilitation RN2 PK12-PK20', 'type' => 'route', 'client' => 2, 'budget' => 3800000000, 'statut' => 'en_cours', 'loc' => 'RN2', 'lots' => [['Terrassement', 1500000000, 80, 'en_cours'], ['Bitume', 2300000000, 20, 'en_cours']]],
        ['code' => 'CH-2026-003', 'nom' => 'Ecole primaire Talatamaty', 'type' => 'batiment', 'client' => 0, 'budget' => 450000000, 'statut' => 'en_cours', 'loc' => 'Talatamaty', 'lots' => [['Batiment', 450000000, 88, 'en_cours']]],
        ['code' => 'CH-2026-004', 'nom' => 'Pont de Mahajanga', 'type' => 'route', 'client' => 2, 'budget' => 5200000000, 'statut' => 'planifie', 'loc' => 'Mahajanga', 'lots' => [['Etudes', 200000000, 30, 'en_cours']]],
        ['code' => 'CH-2026-005', 'nom' => 'Residence Ivandry Park', 'type' => 'batiment', 'client' => 1, 'budget' => 2400000000, 'statut' => 'en_cours', 'loc' => 'Ivandry', 'lots' => [['Fondations', 700000000, 90, 'termine'], ['Elevation', 1700000000, 45, 'en_cours']]],
    ];
    foreach ($chantiers as $x) {
        $id = $ch->creer([
            'code' => $x['code'], 'nom' => $x['nom'], 'type' => $x['type'],
            'client_id' => $cId[$x['client']], 'responsable_id' => $chef, 'localisation' => $x['loc'],
            'budget_previsionnel' => $x['budget'], 'statut' => $x['statut'],
            'date_debut' => date('Y-m-d', strtotime('-4 month')), 'actif' => 1,
        ]);
        $chId[] = $id;
        $ordre = 1;
        foreach ($x['lots'] as $l) {
            $lot->creer(['chantier_id' => $id, 'nom' => $l[0], 'budget_previsionnel' => $l[1], 'avancement' => $l[2], 'statut' => $l[3], 'ordre' => $ordre++]);
        }
    }

    // --- Achats repartis sur 6 mois, imputes aux chantiers, receptionnes (sauf le plus recent) ---
    $achat = new Achat();
    foreach ([5, 4, 3, 2, 1, 0] as $k => $i) {
        $date = date('Y-m-d', strtotime("first day of -$i month") + 5 * 86400);
        $aid = $achat->creerAvecLignes([
            'reference' => 'BC-2026-' . str_pad((string) ($k + 1), 3, '0', STR_PAD_LEFT),
            'fournisseur_id' => $fId[$k % 3], 'chantier_id' => $chId[$k % 5],
            'date_achat' => $date, 'statut' => 'commande', 'cree_par' => $chef,
        ], [
            ['materiau_id' => $mId[0], 'designation' => 'Ciment CEM II', 'quantite' => 100 + $k * 20, 'prix_unitaire' => 38000],
            ['materiau_id' => $mId[2], 'designation' => 'Sable', 'quantite' => 15, 'prix_unitaire' => 60000],
        ]);
        if ($i > 0) {
            receptionnerAchat($aid);
        }
    }

    // --- Pointages : 10 derniers jours, 3 employes, sur le chantier principal ---
    $pt = new Pointage();
    for ($j = 0; $j < 10; $j++) {
        $date = date('Y-m-d', strtotime("-$j day"));
        foreach ([1, 2, 3] as $ei) {
            $e = $emp->trouver($eId[$ei]);
            $type = ($j % 5 === 4) ? 'demi_journee' : 'journee';
            $coef = $type === 'journee' ? 1 : 0.5;
            $pt->enregistrerLigne($chId[0], null, $eId[$ei], $date, $type, (int) round((int) $e['taux_journalier'] * $coef), $chef);
        }
    }

    // --- Factures reparties sur 6 mois + paiements (anciens soldes, recents partiels) ---
    $facture = new Facture();
    $paiement = new Paiement();
    foreach ([5, 4, 3, 2, 1, 0] as $k => $i) {
        $date = date('Y-m-d', strtotime("first day of -$i month") + 10 * 86400);
        $ht = (30 + $k * 8) * 1000000;
        $fid = $facture->creerAvecLignes([
            'reference' => 'FA-2026-' . str_pad((string) ($k + 1), 3, '0', STR_PAD_LEFT),
            'client_id' => $cId[$k % 4], 'chantier_id' => $chId[$k % 5],
            'date_facture' => $date, 'echeance' => date('Y-m-d', strtotime($date . ' +30 day')),
            'statut' => 'brouillon', 'cree_par' => $chef,
        ], [
            ['designation' => 'Situation de travaux', 'quantite' => 1, 'prix_unitaire' => $ht],
        ], 20);
        $facture->modifier($fid, ['statut' => 'emise']);

        $ttc = (int) round($ht * 1.2);
        $montantPaye = ($i >= 2) ? $ttc : (int) round($ttc * 0.6);
        $paiement->creer([
            'facture_id' => $fid, 'date_paiement' => date('Y-m-d', strtotime($date . ' +8 day')),
            'montant' => $montantPaye, 'mode' => 'virement', 'cree_par' => $chef,
        ]);
        $facture->recalculerPaiements($fid);
    }

    // --- Un devis en attente ---
    (new Devis())->creerAvecLignes([
        'reference' => 'DV-2026-010', 'client_id' => $cId[0], 'chantier_id' => $chId[3],
        'date_devis' => date('Y-m-d'), 'statut' => 'envoye', 'cree_par' => $chef,
    ], [['designation' => 'Etudes et travaux pont', 'quantite' => 1, 'prix_unitaire' => 80000000]], 20);

    $db->prepare("INSERT INTO parametres (cle, valeur, description) VALUES ('demo_charge', '1', 'Jeu de donnees de demonstration charge')")->execute();

    echo "Donnees de demonstration chargees :\n";
    echo "  5 chantiers, 4 clients, 3 fournisseurs, 6 employes, 6 materiaux\n";
    echo "  achats + stock, pointages (10 jours), 6 factures + paiements sur 6 mois, 1 devis\n";
    echo "  Comptes crees (mot de passe : Demo@2026) : hery.chef@, naina.compta@, paul.magasin@\n";
}

/** Cree un utilisateur s'il n'existe pas ; retourne son identifiant. */
function ensureUtilisateur(string $email, string $nom, string $prenom, string $role): int
{
    $modele = new Utilisateur();
    $existant = $modele->trouverParEmail($email);
    if ($existant !== null) {
        return (int) $existant['id'];
    }
    return $modele->creer([
        'nom' => $nom, 'prenom' => $prenom, 'email' => $email,
        'mot_de_passe' => password_hash('Demo@2026', PASSWORD_DEFAULT),
        'role' => $role, 'actif' => 1, 'doit_changer_mdp' => 1,
    ]);
}

/** Receptionne un achat de demonstration (entrees de stock + statut recu). */
function receptionnerAchat(int $achatId): void
{
    $modele = new Achat();
    $achat = $modele->trouverAvecLignes($achatId);
    if ($achat === null || $achat['statut'] !== 'commande') {
        return;
    }
    $mv = new MouvementStock();
    foreach ($achat['lignes'] as $ligne) {
        if (empty($ligne['materiau_id'])) {
            continue;
        }
        $mv->enregistrer([
            'materiau_id' => (int) $ligne['materiau_id'], 'type' => 'entree', 'quantite' => $ligne['quantite'],
            'chantier_id' => $achat['chantier_id'], 'achat_id' => $achatId,
            'motif' => 'Reception ' . ($achat['reference'] ?? "#$achatId"), 'date_mouvement' => $achat['date_achat'],
        ]);
    }
    $modele->modifier($achatId, ['statut' => 'recu']);
}

/**
 * Cree un utilisateur a partir des arguments de la ligne de commande.
 *
 * @param string[] $args [email, nom, mot_de_passe, role?]
 */
function creerAdmin(array $args): void
{
    if (count($args) < 3) {
        echo "Usage : php cli.php creer-admin <email> <nom> <mot_de_passe> [role]\n";
        echo "Roles : " . implode(', ', Utilisateur::ROLES) . "\n";
        return;
    }

    [$email, $nom, $motDePasse] = $args;
    $role = $args[3] ?? 'directeur';

    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        echo "Erreur : email invalide.\n";
        return;
    }
    if (!in_array($role, Utilisateur::ROLES, true)) {
        echo "Erreur : role invalide. Choix : " . implode(', ', Utilisateur::ROLES) . "\n";
        return;
    }
    if (strlen($motDePasse) < 8) {
        echo "Erreur : le mot de passe doit contenir au moins 8 caracteres.\n";
        return;
    }

    $modele = new Utilisateur();
    if ($modele->trouverParEmail($email) !== null) {
        echo "Erreur : un compte existe deja avec cet email.\n";
        return;
    }

    $id = $modele->creer([
        'nom'              => $nom,
        'email'            => strtolower(trim($email)),
        'mot_de_passe'     => password_hash($motDePasse, PASSWORD_DEFAULT),
        'role'             => $role,
        'actif'            => 1,
        'doit_changer_mdp' => 0,
    ]);

    echo "Utilisateur cree (#$id) : $email  [role: $role]\n";
}
