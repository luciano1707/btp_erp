<?php

use App\Core\View;

ob_start();
?>
<section class="entete-liste">
    <div><h1 id="titre-doc">Chargement&hellip;</h1><p class="sous-titre" id="statut-doc"></p></div>
    <div class="actions-entete">
        <a class="bouton bouton-secondaire" href="<?= e(url('/factures')) ?>">&larr; Liste</a>
        <a class="bouton bouton-secondaire" id="lien-imprimer" href="#">Imprimer</a>
        <a class="bouton bouton-secondaire" id="lien-recu" href="#" hidden>Re&ccedil;u</a>
        <button class="bouton bouton-primaire" id="btn-emettre" type="button" hidden>Emettre</button>
        <button class="bouton bouton-secondaire" id="btn-annuler" type="button" hidden>Annuler</button>
    </div>
</section>
<div id="zone-doc" hidden>
    <section class="cartes">
        <article class="carte"><h2>Informations</h2><dl class="profil" id="infos-doc"></dl></article>
        <article class="carte">
            <h2>Reglement</h2>
            <dl class="profil">
                <dt>Total TTC</dt><dd id="r-ttc"></dd>
                <dt>Deja paye</dt><dd id="r-paye"></dd>
                <dt>Reste du</dt><dd id="r-reste"></dd>
            </dl>
            <form id="form-paiement" hidden>
                <div class="grille-2">
                    <div class="champ"><label for="p-montant">Montant (Ar)</label><input type="number" id="p-montant" min="1" required></div>
                    <div class="champ"><label for="p-mode">Mode</label>
                        <select id="p-mode">
                            <option value="especes">Especes</option><option value="virement">Virement</option>
                            <option value="cheque">Cheque</option><option value="mobile_money">Mobile Money</option><option value="autre">Autre</option>
                        </select>
                    </div>
                </div>
                <div class="actions-form"><button type="submit" class="bouton bouton-primaire">Enregistrer le paiement</button></div>
            </form>
        </article>
    </section>
    <section style="margin-top:20px">
        <h2>Lignes</h2>
        <div class="tableau-enveloppe"><table class="tableau">
            <thead><tr><th>Designation</th><th>Quantite</th><th>Prix unit.</th><th>Montant</th></tr></thead>
            <tbody id="corps-lignes"></tbody>
        </table></div>
        <dl class="profil totaux"><dt>HT</dt><dd id="t-ht"></dd><dt>TVA</dt><dd id="t-tva"></dd><dt>TTC</dt><dd id="t-ttc"></dd></dl>
    </section>
    <section style="margin-top:20px">
        <h2>Paiements</h2>
        <div class="tableau-enveloppe"><table class="tableau">
            <thead><tr><th>Date</th><th>Montant</th><th>Mode</th><th>Reference</th></tr></thead>
            <tbody id="corps-paiements"></tbody>
        </table></div>
    </section>
</div>
<?php
$contenu = ob_get_clean();
View::rendre('layouts.base', [
    'titre' => $titre, 'contenu' => $contenu,
    'scripts' => ['js/auth.js', 'js/format.js', 'js/facture-detail.js'],
    'config_json' => ['id' => $id, 'peutValider' => $peutValider ?? false, 'peutPayer' => $peutPayer ?? false, 'peutAnnuler' => $peutAnnuler ?? false],
]);
