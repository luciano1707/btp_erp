<?php
/**
 * Sommaire des referentiels : cartes premium avec icone, compteur en direct (API) et CTA.
 * Les totaux sont charges en AJAX par referentiels.js (window.REFERENTIELS).
 * @var string $titre
 * @var array<string,mixed> $config
 */

use App\Core\View;

ob_start();
?>
<section class="hero">
    <h1>R&eacute;f&eacute;rentiels</h1>
    <p class="sous-titre">Donn&eacute;es de base de l'entreprise : employ&eacute;s, clients, fournisseurs, engins, mat&eacute;riaux.</p>
</section>

<section class="grille-referentiels" id="grille-referentiels">
    <?php foreach ($config as $cle => $conf): ?>
        <a class="carte-referentiel" href="<?= e(url('/referentiels/' . $cle)) ?>" data-entite="<?= e($cle) ?>" data-endpoint="<?= e($conf['endpoint']) ?>">
            <span class="cr-haut">
                <span class="cr-icone" aria-hidden="true">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" width="22" height="22"><?= referentiel_icone_chemin($cle) ?></svg>
                </span>
                <span class="cr-fleche" aria-hidden="true">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="18" height="18"><path d="M5 12h14"/><path d="M13 6l6 6-6 6"/></svg>
                </span>
            </span>
            <span class="cr-contenu">
                <span class="cr-titre"><?= e($conf['libelle_pluriel']) ?></span>
                <span class="cr-meta">G&eacute;rer les <?= e(mb_strtolower($conf['libelle_pluriel'])) ?></span>
                <span class="cr-stats">
                    <span class="cr-total squelette" data-compteur>&hellip;</span>
                    <span class="cr-libelle">enregistrements</span>
                </span>
            </span>
        </a>
    <?php endforeach; ?>
</section>

<section class="etat-vide" id="referentiels-vide" hidden>
    <p><strong>Aucun r&eacute;f&eacute;rentiel.</strong></p>
    <p>Ajoutez des donn&eacute;es de base depuis la liste correspondante.</p>
</section>

<div class="conteneur-toasts" id="conteneur-toasts" aria-live="polite"></div>
<?php
$contenu = ob_get_clean();

$configJs = [];
foreach ($config as $cle => $conf) {
    $configJs[$cle] = [
        'libelle' => $conf['libelle_pluriel'],
        'endpoint' => $conf['endpoint'],
    ];
}

View::rendre('layouts.base', [
    'titre'       => $titre,
    'contenu'     => $contenu,
    'scripts'     => ['js/auth.js', 'js/referents.js'],
    'config_json' => $configJs,
]);
