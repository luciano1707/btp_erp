<?php

use App\Core\View;

ob_start();
?>
<section class="entete-liste">
    <div><h1>Stock</h1><p class="sous-titre description-liste">Suivez les niveaux de materiaux et identifiez rapidement les seuils a reapprovisionner.</p><p class="sous-titre" id="compteur">Chargement&hellip;</p></div>
</section>
<div class="barre-recherche">
    <label class="champ-recherche">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="17" height="17" aria-hidden="true"><circle cx="11" cy="11" r="7"/><path d="M21 21l-4.3-4.3"/></svg>
        <input type="search" id="recherche-stock" placeholder="Rechercher un materiau..." autocomplete="off">
    </label>
</div>
<div class="tableau-enveloppe">
    <table class="tableau">
        <thead><tr><th>Code</th><th>Materiau</th><th>Unite</th><th>Stock actuel</th><th>Seuil</th><?php if (!empty($peutEcrire)): ?><th class="col-actions">Mouvements</th><?php endif; ?></tr></thead>
        <tbody id="corps-tableau"><tr><td class="vide" colspan="<?= 5 + (int) !empty($peutEcrire) ?>">Chargement&hellip;</td></tr></tbody>
    </table>
</div>
<?php
$contenu = ob_get_clean();
View::rendre('layouts.base', [
    'titre'   => $titre,
    'contenu' => $contenu,
    'scripts'     => ['js/auth.js', 'js/format.js', 'js/stock.js'],
    'config_json' => ['peutEcrire' => !empty($peutEcrire)],
]);
