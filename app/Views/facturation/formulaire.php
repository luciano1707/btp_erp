<?php

use App\Core\View;

ob_start();
?>
<section class="entete-liste"><h1><?= e($titre) ?></h1></section>

<form id="form-doc" class="carte formulaire-large">
    <div class="grille-2">
        <div class="champ"><label for="reference">Reference</label><input type="text" id="reference" data-entete></div>
        <div class="champ"><label for="<?= e($champDate) ?>">Date *</label><input type="date" id="<?= e($champDate) ?>" data-entete required></div>
    </div>
    <div class="grille-2">
        <div class="champ"><label for="client_id">Client</label><select id="client_id" data-entete><option value="">— Aucun —</option></select></div>
        <div class="champ"><label for="chantier_id">Chantier</label><select id="chantier_id" data-entete><option value="">— Aucun —</option></select></div>
    </div>
    <div class="grille-2">
        <div class="champ"><label for="<?= e($champEcheance) ?>"><?= e($libelleEcheance) ?></label><input type="date" id="<?= e($champEcheance) ?>" data-entete></div>
        <div class="champ"><label for="tva_taux">TVA (%)</label><input type="number" id="tva_taux" value="20" min="0" step="0.01"></div>
    </div>
    <div class="champ"><label for="notes">Notes</label><input type="text" id="notes" data-entete></div>

    <h3>Lignes</h3>
    <div class="tableau-enveloppe">
        <table class="tableau">
            <thead><tr><th>Designation</th><th>Quantite</th><th>Prix unit. (Ar)</th><th>Montant</th><th></th></tr></thead>
            <tbody id="corps-lignes"></tbody>
        </table>
    </div>
    <button type="button" class="bouton bouton-secondaire" id="btn-ajouter-ligne" style="margin-top:12px">+ Ajouter une ligne</button>

    <dl class="profil totaux">
        <dt>Total HT</dt><dd id="total-ht">0 Ar</dd>
        <dt>TVA</dt><dd id="total-tva">0 Ar</dd>
        <dt>Total TTC</dt><dd id="total-ttc"><strong>0 Ar</strong></dd>
    </dl>

    <div id="message-erreur" class="message-erreur" hidden></div>
    <div class="actions-form">
        <button type="submit" id="btn-enregistrer" class="bouton bouton-primaire">Enregistrer</button>
        <a class="bouton bouton-secondaire" href="<?= e(url($baseWeb)) ?>">Annuler</a>
    </div>
</form>
<?php
$contenu = ob_get_clean();
View::rendre('layouts.base', [
    'titre'       => $titre,
    'contenu'     => $contenu,
    'scripts'     => ['js/auth.js', 'js/format.js', 'js/doc-form.js'],
    'config_json' => ['endpoint' => $endpoint, 'baseWeb' => rtrim($baseWeb, '/')],
]);
