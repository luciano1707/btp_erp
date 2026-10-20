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
<?php if (!empty($peutEcrire)): ?>
    <p id="stock-notice" class="stock-notice" role="status" hidden></p>
<?php endif; ?>
<div class="tableau-enveloppe">
    <table class="tableau">
        <thead><tr><th>Code</th><th>Materiau</th><th>Unite</th><th>Stock actuel</th><th>Seuil</th><?php if (!empty($peutEcrire)): ?><th class="col-actions">Mouvements</th><?php endif; ?></tr></thead>
        <tbody id="corps-tableau"><tr><td class="vide" colspan="<?= 5 + (int) !empty($peutEcrire) ?>">Chargement&hellip;</td></tr></tbody>
    </table>
</div>
<?php if (!empty($peutEcrire)): ?>
    <div class="modal-voile" id="modal-mouvement" hidden>
        <section class="modal-carte" role="dialog" aria-modal="true" aria-labelledby="titre-mouvement" aria-describedby="description-mouvement">
            <h3 id="titre-mouvement">Mouvement de stock</h3>
            <p id="description-mouvement"></p>
            <form id="form-mouvement">
                <div class="champ">
                    <label for="mouvement-quantite" id="label-quantite">Quantite *</label>
                    <input type="number" id="mouvement-quantite" min="0.001" step="0.001" required inputmode="decimal">
                </div>
                <div class="champ">
                    <label for="mouvement-motif">Motif (facultatif)</label>
                    <input type="text" id="mouvement-motif" maxlength="255">
                </div>
                <div id="mouvement-erreur" class="message-erreur" role="alert" hidden></div>
                <div class="actions-form">
                    <button type="submit" class="bouton bouton-primaire" id="btn-enregistrer-mouvement">Enregistrer</button>
                    <button type="button" class="bouton bouton-secondaire" id="btn-annuler-mouvement">Annuler</button>
                </div>
            </form>
        </section>
    </div>
<?php endif; ?>
<?php
$contenu = ob_get_clean();
View::rendre('layouts.base', [
    'titre'   => $titre,
    'contenu' => $contenu,
    'scripts'     => ['js/auth.js', 'js/format.js', 'js/stock.js'],
    'config_json' => ['peutEcrire' => !empty($peutEcrire)],
]);
