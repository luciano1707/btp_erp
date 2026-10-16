<?php
/**
 * Liste des chantiers.
 * @var string $titre
 * @var array<string,string> $statuts
 * @var bool $peutCreer
 * @var bool $peutModifier
 * @var bool $peutVoirFinances
 */

use App\Core\View;

ob_start();
?>
<section class="entete-liste">
    <div>
        <h1>Chantiers</h1>
        <p class="sous-titre description-liste">Suivez vos projets, leurs budgets, leurs clients et leur avancement.</p>
        <p class="sous-titre" id="compteur">Chargement&hellip;</p>
    </div>
    <?php if ($peutCreer): ?>
        <a class="bouton bouton-primaire" href="<?= e(url('/chantiers/nouveau')) ?>">+ Nouveau chantier</a>
    <?php endif; ?>
</section>

<div class="barre-recherche">
    <input type="search" id="recherche" placeholder="Rechercher un chantier&hellip;" autocomplete="off">
</div>

<div class="tableau-enveloppe">
    <table class="tableau">
        <thead>
            <tr>
                <th>Code</th>
                <th>Nom</th>
                <th>Type</th>
                <th>Client</th>
                <?php if ($peutVoirFinances): ?><th>Budget prev.</th><?php endif; ?>
                <th>Statut</th>
                <?php if ($peutModifier): ?><th class="col-actions">Actions</th><?php endif; ?>
            </tr>
        </thead>
        <tbody id="corps-tableau">
            <tr><td class="vide" colspan="<?= 5 + (int) $peutVoirFinances + (int) $peutModifier ?>">Chargement&hellip;</td></tr>
        </tbody>
    </table>
</div>
<?php
$contenu = ob_get_clean();

View::rendre('layouts.base', [
    'titre'       => $titre,
    'contenu'     => $contenu,
    'scripts'     => ['js/auth.js', 'js/format.js', 'js/chantier-liste.js'],
    'config_json' => [
        'statuts' => $statuts,
        'peutCreer' => $peutCreer,
        'peutModifier' => $peutModifier,
        'peutVoirFinances' => $peutVoirFinances,
    ],
]);
