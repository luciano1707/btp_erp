<?php

use App\Core\View;

ob_start();
?>
<section class="entete-liste"><h1>Nouvel achat</h1></section>

<form id="form-achat" class="carte formulaire-large">
    <div class="grille-2">
        <div class="champ"><label for="reference">Reference</label><input type="text" id="reference" placeholder="BC-2026-001"></div>
        <div class="champ"><label for="date_achat">Date *</label><input type="date" id="date_achat" required></div>
    </div>
    <div class="grille-2">
        <div class="champ"><label for="fournisseur_id">Fournisseur</label><select id="fournisseur_id"><option value="">— Aucun —</option></select></div>
        <div class="champ"><label for="chantier_id">Chantier (imputation)</label><select id="chantier_id"><option value="">— Aucun —</option></select></div>
    </div>
    <div class="champ"><label for="notes">Notes</label><input type="text" id="notes"></div>

    <h3>Lignes d'achat</h3>
    <div class="tableau-enveloppe">
        <table class="tableau">
            <thead><tr><th>Materiau</th><th>Designation</th><th>Quantite</th><th>Prix unit. (Ar)</th><th>Montant</th><th></th></tr></thead>
            <tbody id="corps-lignes"></tbody>
            <tfoot><tr><td colspan="4" style="text-align:right;font-weight:600">Total</td><td id="total-achat" style="font-weight:700">0 Ar</td><td></td></tr></tfoot>
        </table>
    </div>
    <button type="button" class="bouton bouton-secondaire" id="btn-ajouter-ligne" style="margin-top:12px">+ Ajouter une ligne</button>

    <div id="message-erreur" class="message-erreur" hidden style="margin-top:16px"></div>
    <div class="actions-form" style="margin-top:16px">
        <button type="submit" id="btn-enregistrer" class="bouton bouton-primaire">Enregistrer l'achat</button>
        <a class="bouton bouton-secondaire" href="<?= e(url('/achats')) ?>">Annuler</a>
    </div>
</form>
<?php
$contenu = ob_get_clean();
View::rendre('layouts.base', [
    'titre'   => $titre,
    'contenu' => $contenu,
    'scripts' => ['js/auth.js', 'js/format.js', 'js/achat-form.js'],
]);
