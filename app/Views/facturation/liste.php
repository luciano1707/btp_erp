<?php

use App\Core\View;

ob_start();
?>
<section class="entete-liste">
    <div><h1><?= e($titre) ?></h1><p class="sous-titre description-liste">Retrouvez vos documents commerciaux, leurs montants et leurs statuts.</p><p class="sous-titre" id="compteur">Chargement&hellip;</p></div>
    <div class="actions-groupe">
        <?php if (!empty($peutCreer)): ?><a class="bouton bouton-primaire" href="<?= e(url($nouveau)) ?>">+ Nouveau</a><?php endif; ?>
        <div class="groupe-export">
            <button class="bouton bouton-export" type="button" onclick="exporter('pdf')">📄 PDF</button>
            <button class="bouton bouton-export bouton-export-excel" type="button" onclick="exporter('xlsx')">📊 Excel</button>
        </div>
    </div>
</section>
<div class="barre-recherche"><input type="search" id="recherche" placeholder="Rechercher&hellip;"></div>
<div class="tableau-enveloppe">
    <table class="tableau">
        <thead><tr><th>Reference</th><th>Client</th><th>Date</th><th>Montant TTC</th><th>Statut</th><th class="col-actions">Actions</th></tr></thead>
        <tbody id="corps-tableau"><tr><td class="vide" colspan="6">Chargement&hellip;</td></tr></tbody>
    </table>
</div>
<?php
$contenu = ob_get_clean();
View::rendre('layouts.base', [
    'titre'       => $titre,
    'contenu'     => $contenu,
    'scripts'     => ['js/auth.js', 'js/format.js', 'js/doc-liste.js'],
    'config_json' => [
        'endpoint' => $endpoint,
        'baseWeb'  => rtrim($baseWeb, '/'),
        'champDate' => $type === 'devis' ? 'date_devis' : 'date_facture',
        'statuts'  => $statuts,
    ],
]);
