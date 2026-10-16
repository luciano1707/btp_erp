<?php
/**
 * Liste d'un referentiel (tableau premium charge en AJAX depuis l'API).
 * - Tri de colonnes, recherche, squelette de chargement, etat vide, toasts.
 * - Confirmation native stylisee (dialog) fournie en JS (ressource-liste.js).
 * @var string $titre
 * @var string $entite
 * @var array<string,mixed> $config
 * @var bool $peutCreer
 * @var bool $peutModifier
 * @var bool $peutSupprimer
 */

use App\Core\View;

ob_start();
?>
<section class="entete-liste">
    <div>
        <h1><?= e($config['libelle_pluriel']) ?></h1>
        <p class="sous-titre description-liste">Gerez les donnees de base utilisees par votre entreprise.</p>
        <p class="sous-titre" id="compteur">Chargement&hellip;</p>
    </div>
    <?php if ($peutCreer): ?>
        <a class="bouton bouton-primaire" href="<?= e(url('/referentiels/' . $entite . '/nouveau')) ?>">
            <span class="bouton-icone">+</span> Ajouter
        </a>
    <?php endif; ?>
</section>

<section class="barre-recherche">
    <label class="champ-recherche">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="17" height="17" aria-hidden="true"><circle cx="11" cy="11" r="7"/><path d="M21 21l-4.3-4.3"/></svg>
        <input type="search" id="recherche" placeholder="Rechercher&hellip;" autocomplete="off">
    </label>
</section>

<div class="tableau-enveloppe">
    <table class="tableau">
        <thead>
            <tr>
                <?php foreach ($config['colonnes'] as $i => $col): ?>
                    <th class="triable<?= $i === 0 ? ' tri-asc' : '' ?>" data-tri="<?= e($col['champ']) ?>" aria-sort="<?= $i === 0 ? 'ascending' : 'none' ?>">
                        <?= e($col['libelle']) ?>
                    </th>
                <?php endforeach; ?>
                <?php if ($peutModifier || $peutSupprimer): ?><th class="col-actions">Actions</th><?php endif; ?>
            </tr>
        </thead>
        <tbody id="corps-tableau">
            <tr class="ligne-squelette">
                <?php for ($j = 0; $j < count($config['colonnes']) + (int) ($peutModifier || $peutSupprimer); $j++): ?>
                    <td><span class="squelette"></span></td>
                <?php endfor; ?>
            </tr>
        </tbody>
    </table>
</div>

<div class="etat-vide" id="referentiels-vide" hidden>
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="11" cy="11" r="7"/><path d="M21 21l-4.3-4.3"/><path d="M8.5 11h5"/></svg>
    <strong>Aucun r&eacute;sultat</strong>
    <p>Ajustez votre recherche ou ajoutez un premier enregistrement.</p>
    <?php if ($peutCreer): ?>
        <a class="bouton bouton-secondaire" href="<?= e(url('/referentiels/' . $entite . '/nouveau')) ?>">+ Ajouter</a>
    <?php endif; ?>
</div>

<div class="conteneur-toasts" id="conteneur-toasts" aria-live="polite"></div>
<?php
$contenu = ob_get_clean();

$configJs = [
    'entite'    => $entite,
    'endpoint'  => $config['endpoint'],
    'colonnes'  => $config['colonnes'],
    'libelle'   => $config['libelle'],
    'retour'    => url('/referentiels/' . $entite),
    'peutCreer' => $peutCreer,
    'peutModifier' => $peutModifier,
    'peutSupprimer' => $peutSupprimer,
];

View::rendre('layouts.base', [
    'titre'       => $titre,
    'contenu'     => $contenu,
    'scripts'     => ['js/auth.js', 'js/ressource-liste.js'],
    'config_json' => $configJs,
]);
