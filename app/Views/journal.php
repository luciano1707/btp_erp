<?php

use App\Core\View;

ob_start();
?>
<section class="entete-liste">
    <div><h1>Journal d'audit</h1><p class="sous-titre description-liste">Consultez l'historique des actions et des changements effectues dans l'application.</p><p class="sous-titre" id="compteur">Chargement&hellip;</p></div>
</section>
<div class="barre-recherche" style="display:flex;gap:12px;flex-wrap:wrap">
    <input type="search" id="filtre-action" placeholder="Filtrer par action (ex: facture)&hellip;">
</div>
<div class="tableau-enveloppe">
    <table class="tableau">
        <thead><tr><th>Date</th><th>Utilisateur</th><th>Action</th><th>Entite</th><th>Details</th><th>IP</th></tr></thead>
        <tbody id="corps-tableau"><tr><td class="vide" colspan="6">Chargement&hellip;</td></tr></tbody>
    </table>
</div>
<div class="pagination"><button class="bouton bouton-secondaire" id="btn-precedent">&larr;</button>
    <span id="info-page"></span>
    <button class="bouton bouton-secondaire" id="btn-suivant">&rarr;</button></div>
<?php
$contenu = ob_get_clean();
View::rendre('layouts.base', [
    'titre'   => $titre,
    'contenu' => $contenu,
    'scripts' => ['js/auth.js', 'js/format.js', 'js/journal.js'],
]);
