<?php

use App\Core\View;

ob_start();
?>
<section class="entete-liste"><h1>Suivi financier</h1></section>

<div class="grille-tdb" style="margin-bottom:20px">
    <article class="carte">
        <div class="entete-graphique">
            <div><h2>Facture vs encaisse</h2><p class="sous-titre">6 derniers mois &middot; en Ariary</p></div>
            <div class="legende"><span class="pastille pastille-bleu"></span> Facture <span class="pastille pastille-vert"></span> Encaisse</div>
        </div>
        <div id="graphique-mensuel"><p class="chargement">Chargement&hellip;</p></div>
    </article>
    <article class="carte">
        <h2>Co&ucirc;ts par chantier</h2>
        <p class="sous-titre" style="margin-bottom:8px">Main d'&oelig;uvre + mat&eacute;riaux engag&eacute;s.</p>
        <div id="donut-couts"><p class="chargement">Chargement&hellip;</p></div>
    </article>
</div>

<section class="carte" style="margin-bottom:20px">
    <h2>Tresorerie</h2>
    <div class="barre-recherche" style="display:flex;gap:12px;flex-wrap:wrap">
        <label>Du <input type="date" id="treso-debut"></label>
        <label>au <input type="date" id="treso-fin"></label>
        <button class="bouton bouton-secondaire" id="btn-treso">Actualiser</button>
    </div>
    <dl class="profil" id="bloc-tresorerie">
        <dt>Encaissements</dt><dd id="tr-enc">—</dd>
        <dt>Decaissements</dt><dd id="tr-dec">—</dd>
        <dt>Solde</dt><dd id="tr-solde">—</dd>
    </dl>
</section>

<h2>Rentabilite par chantier</h2>
<div class="tableau-enveloppe">
    <table class="tableau">
        <thead><tr><th>Chantier</th><th>Budget</th><th>Cout MO</th><th>Cout mat.</th><th>Cout total</th><th>Facture</th><th>Encaisse</th><th>Marge</th></tr></thead>
        <tbody id="corps-chantiers"><tr><td class="vide" colspan="8">Chargement&hellip;</td></tr></tbody>
    </table>
</div>
<?php
$contenu = ob_get_clean();
View::rendre('layouts.base', [
    'titre'   => $titre,
    'contenu' => $contenu,
    'scripts' => ['js/auth.js', 'js/format.js', 'js/charts.js', 'js/finances.js'],
]);
