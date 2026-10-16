<?php

use App\Core\View;

ob_start();
?>
<section class="entete-liste">
    <div><h1 id="titre-achat">Chargement&hellip;</h1><p class="sous-titre" id="sous-titre-achat"></p></div>
    <div class="actions-entete">
        <a class="bouton bouton-secondaire" href="<?= e(url('/achats')) ?>">&larr; Liste</a>
        <button class="bouton bouton-primaire" id="btn-reception" type="button" hidden>Receptionner (entree stock)</button>
        <button class="bouton bouton-secondaire" id="btn-annuler" type="button" hidden>Annuler</button>
    </div>
</section>

<div id="zone-achat" hidden>
    <section class="cartes">
        <article class="carte"><h2>Informations</h2><dl class="profil" id="infos-achat"></dl></article>
    </section>
    <section style="margin-top:20px">
        <h2>Lignes</h2>
        <div class="tableau-enveloppe">
            <table class="tableau">
                <thead><tr><th>Designation</th><th>Quantite</th><th>Prix unit.</th><th>Montant</th></tr></thead>
                <tbody id="corps-lignes"></tbody>
                <tfoot><tr><td colspan="3" style="text-align:right;font-weight:600">Total</td><td id="total-achat" style="font-weight:700"></td></tr></tfoot>
            </table>
        </div>
    </section>
</div>
<?php
$contenu = ob_get_clean();
View::rendre('layouts.base', [
    'titre'       => $titre,
    'contenu'     => $contenu,
    'scripts'     => ['js/auth.js', 'js/format.js', 'js/achat-detail.js'],
    'config_json' => ['id' => $id, 'peutReceptionner' => $peutReceptionner ?? false, 'peutAnnuler' => $peutAnnuler ?? false],
]);
