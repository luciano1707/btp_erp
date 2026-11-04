<?php
/**
 * Gabarit de base.
 * - Mode "app" (defaut) : sidebar de navigation + topbar.
 * - Mode "bare" ($bare = true) : page centree sans chrome (connexion, impression, 404).
 * Variables : $titre (string), $contenu (string HTML), $scripts (string[]), $config_json (array), $bare (bool).
 */
$nomApp = \App\Core\Env::get('APP_NAME', 'Digital Chantier');
$sigle  = \App\Core\Env::get('BRAND_SIGLE', 'DC');
$couleur = \App\Core\Env::get('BRAND_COLOR', '#2c6ea4');
$bare = !empty($bare);

/** Elements de navigation de la sidebar, groupes par section. */
$navigation = [
    'Pilotage' => [
        ['/tableau-de-bord', 'Tableau de bord', 'grille', 'tableau_de_bord'],
        ['/chantiers', 'Chantiers', 'batiment', 'chantiers'],
        ['/finances', 'Finances', 'graphique', 'finances'],
    ],
    'Opérations' => [
        ['/rapports-journaliers', 'Rapports journaliers', 'document', 'rapports_journaliers'],
        ['/demandes-materiel', 'Demandes de matériel', 'panier', 'demandes_materiel'],
    ],
    'Approvisionnement' => [
        ['/achats', 'Achats', 'panier', 'achats'],
        ['/stock', 'Stock', 'boite', 'stock'],
        ['/referentiels/fournisseurs', 'Fournisseurs', 'base', 'fournisseurs'],
    ],
    'Commercial' => [
        ['/devis', 'Devis', 'document', 'devis'],
        ['/factures', 'Factures', 'recu', 'factures'],
    ],
    'Suivi financier' => [
        ['/depenses', 'Dépenses', 'recu', 'depenses'],
        ['/budgets', 'Budgets', 'graphique', 'budgets'],
    ],
    'Qualité / Sécurité' => [
        ['/rfi', 'RFI', 'document', 'rfi'],
        ['/qualite', 'Qualité', 'liste', 'qualite'],
        ['/securite', 'Sécurité', 'liste', 'securite'],
        ['/incidents', 'Incidents', 'liste', 'incidents'],
    ],
    'Données' => [
        ['/referentiels', 'Référentiels', 'base', 'referentiels'],
        ['/notifications', 'Notifications', 'liste', 'notifications'],
        ['/journal', 'Journal d\'audit', 'liste', 'journal'],
        ['/profil', 'Mon profil', 'engrenage', 'profil'],
        ['/parametres', 'Paramètres', 'engrenage', 'parametres'],
    ],
];

/** Rendu d'une icone SVG (stroke). */
function icone(string $nom): string
{
    $chemins = [
        'grille'    => '<rect x="3" y="3" width="7" height="7" rx="1.5"/><rect x="14" y="3" width="7" height="7" rx="1.5"/><rect x="3" y="14" width="7" height="7" rx="1.5"/><rect x="14" y="14" width="7" height="7" rx="1.5"/>',
        'batiment'  => '<path d="M3 21h18"/><path d="M6 21V7l7-4 7 4v14"/><path d="M10 9h0M10 13h0M10 17h0"/>',
        'graphique' => '<path d="M3 3v18h18"/><path d="M7 15l3-4 3 2 4-6"/>',
        'panier'    => '<circle cx="9" cy="20" r="1"/><circle cx="18" cy="20" r="1"/><path d="M2 3h2l2.4 12.3a1 1 0 0 0 1 .7h9.7a1 1 0 0 0 1-.8L21 7H5"/>',
        'boite'     => '<path d="M21 8V16a1 1 0 0 1-.5.9l-7 4a1 1 0 0 1-1 0l-7-4A1 1 0 0 1 3 16V8"/><path d="M3.3 7.5l8.2 4.5 8.2-4.5"/><path d="M12 12v9"/><path d="M20 7.5l-8-4.5-8 4.5"/>',
        'document'  => '<path d="M14 3H7a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V8z"/><path d="M14 3v5h5"/><path d="M9 13h6M9 17h6"/>',
        'recu'      => '<path d="M5 3v18l2-1 2 1 2-1 2 1 2-1 2 1V3l-2 1-2-1-2 1-2-1-2 1z"/><path d="M9 8h6M9 12h6"/>',
        'base'      => '<ellipse cx="12" cy="5" rx="8" ry="3"/><path d="M4 5v6c0 1.7 3.6 3 8 3s8-1.3 8-3V5"/><path d="M4 11v6c0 1.7 3.6 3 8 3s8-1.3 8-3v-6"/>',
        'liste'     => '<path d="M8 6h13M8 12h13M8 18h13"/><path d="M3 6h0M3 12h0M3 18h0"/>',
        'engrenage' => '<circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/>',
    ];
    $contenu = $chemins[$nom] ?? '';
    return '<svg class="nav-icone" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">' . $contenu . '</svg>';
}
?>
<!doctype html>
<html lang="fr">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><?= e($titre ?? '') ?> &middot; <?= e($nomApp) ?></title>
    <link rel="stylesheet" href="<?= e(asset('css/app.css')) ?>">
    <style>
        :root {
            --primaire: <?= e($couleur) ?>;
            --primaire-fonce: <?= e(teinte($couleur, -0.15)) ?>;
            --primaire-clair: <?= e(teinte($couleur, 0.88)) ?>;
        }
    </style>
    <script>
        window.APP_BASE = <?= json_encode(base_url()) ?>;
        window.APP_DESKTOP = <?= json_encode((bool) \App\Core\Env::get('APP_DESKTOP', false)) ?>;
        <?php if (!empty($config_json)): ?>
        window.RESSOURCE = <?= json_encode($config_json, JSON_UNESCAPED_UNICODE) ?>;
        <?php endif; ?>
    </script>
</head>
<?php if ($bare): ?>
<body class="page-bare">
    <main class="contenu-bare"><?= $contenu ?? '' ?></main>
<?php else: ?>
<body class="app-shell">
    <aside class="sidebar" id="sidebar">
        <div class="sidebar-marque">
            <span class="sidebar-logo"><?= e($sigle) ?></span>
            <span class="sidebar-nom"><?= e($nomApp) ?></span>
            <button class="sidebar-fermer" id="btn-menu-fermer" type="button" aria-label="Fermer le menu">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><path d="M18 6L6 18M6 6l12 12"/></svg>
            </button>
        </div>
        <nav class="sidebar-nav">
            <?php foreach ($navigation as $section => $items): ?>
                <p class="sidebar-section"><?= e(mb_strtoupper($section)) ?></p>
                <?php foreach ($items as [$href, $libelle, $ic, $module]): ?>
                    <a class="nav-item" href="<?= e(url($href)) ?>" data-chemin="<?= e($href) ?>" data-module="<?= e($module) ?>">
                        <?= icone($ic) ?><span><?= e($libelle) ?></span>
                    </a>
                <?php endforeach; ?>
            <?php endforeach; ?>
        </nav>
        <div class="sidebar-pied">
            <strong><?= e($nomApp) ?></strong> &middot; v1.0<br>
            Mahajanga, MG
        </div>
    </aside>

    <div class="main">
        <header class="topbar">
            <div class="topbar-gauche">
                <button class="bouton-menu" id="btn-menu" type="button" aria-label="Ouvrir le menu" aria-controls="sidebar" aria-expanded="false">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" aria-hidden="true"><path d="M4 7h16M4 12h16M4 17h16"/></svg>
                </button>
                <div class="topbar-icone" aria-hidden="true">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" width="26" height="26">
                        <rect x="3" y="5" width="18" height="14" rx="2"/>
                        <path d="M8 3v4M16 3v4M3 10h18"/>
                    </svg>
                </div>
                <h1 class="topbar-titre"><?= e($titre ?? '') ?></h1>
            </div>
            <div class="topbar-droite">
                <div class="cloche-conteneur">
                    <button class="cloche" id="cloche" type="button" title="Alertes" aria-label="Alertes">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" width="20" height="20"><path d="M18 8a6 6 0 0 0-12 0c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.7 21a2 2 0 0 1-3.4 0"/></svg>
                        <span class="badge-cloche" id="badge-cloche" hidden>0</span>
                    </button>
                    <div class="cloche-panneau" id="cloche-panneau" hidden></div>
                </div>
                <div class="topbar-user">
                    <span class="topbar-user-nom" id="topbar-user-nom">&hellip;</span>
                    <span class="topbar-user-role" id="topbar-user-role">&nbsp;</span>
                </div>
                <button class="btn-deco" id="btn-deconnexion-shell" title="Se deconnecter" type="button">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" width="18" height="18"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><path d="M16 17l5-5-5-5"/><path d="M21 12H9"/></svg>
                </button>
            </div>
        </header>
        <main class="contenu"><?= $contenu ?? '' ?></main>
    </div>
<?php endif; ?>

    <script src="<?= e(asset('js/export.js')) ?>"></script>
    <?php
    $lesScripts = !empty($scripts) ? $scripts : [];
    foreach ($lesScripts as $s):
        ?>
        <script src="<?= e(asset($s)) ?>"></script>
    <?php endforeach; ?>
    <?php if (!$bare): ?>
        <script src="<?= e(asset('js/app-shell.js')) ?>"></script>
        <script src="<?= e(asset('js/select-recherche.js')) ?>"></script>
    <?php endif; ?>
</body>
</html>
