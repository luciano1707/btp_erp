<?php

use App\Core\View;

ob_start();
?>
<section class="entete-liste">
    <div><h1 id="titre-doc">Chargement&hellip;</h1><p class="sous-titre" id="statut-doc"></p></div>
    <div class="actions-entete">
        <a class="bouton bouton-secondaire" href="<?= e(url('/devis')) ?>">&larr; Liste</a>
        <a class="bouton bouton-secondaire" id="lien-imprimer" href="#">Imprimer</a>
        <button class="bouton bouton-secondaire" id="btn-export-pdf" type="button" hidden>Export PDF</button>
        <button class="bouton bouton-secondaire" id="btn-envoyer" type="button" hidden>Soumettre au directeur</button>
        <button class="bouton bouton-primaire" id="btn-accepter" type="button" hidden>Accepter</button>
        <button class="btn btn-rouge" id="btn-refuser" type="button" hidden>Refuser</button>
        <button class="bouton bouton-primaire" id="btn-facturer" type="button" hidden>Facturer</button>
    </div>
</section>
<div id="zone-doc" hidden>
    <section class="cartes"><article class="carte"><h2>Informations</h2><dl class="profil" id="infos-doc"></dl></article></section>
    <section style="margin-top:20px">
        <h2>Lignes</h2>
        <div class="tableau-enveloppe"><table class="tableau">
            <thead><tr><th>Designation</th><th>Quantite</th><th>Prix unit.</th><th>Montant</th></tr></thead>
            <tbody id="corps-lignes"></tbody>
        </table></div>
        <dl class="profil totaux">
            <dt>Total HT</dt><dd id="t-ht"></dd>
            <dt>TVA</dt><dd id="t-tva"></dd>
            <dt>Total TTC</dt><dd id="t-ttc"></dd>
        </dl>
    </section>
</div>
<?php
$contenu = ob_get_clean();
View::rendre('layouts.base', [
    'titre' => $titre, 'contenu' => $contenu,
    'scripts' => ['js/auth.js', 'js/format.js', 'js/devis-detail.js'],
    'config_json' => [
        'id' => $id,
        'peutSoumettre' => $peutSoumettre ?? false,
        'peutValider' => $peutValider ?? false,
        'peutFacturer' => $peutFacturer ?? false,
    ],
]);
