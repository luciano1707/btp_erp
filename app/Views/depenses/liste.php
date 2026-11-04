<?php
/**
 * @var string $titre
 * @var bool $peutCreer
 */
use App\Core\View;

ob_start();
?>
<div class="barre-actions">
    <?php if (!empty($peutCreer)): ?><a class="btn btn-primaire" href="<?= e(url('/depenses/nouveau')) ?>">Nouvelle dépense</a><?php endif; ?>
    <div class="groupe-export">
        <button class="btn bouton-export" type="button" onclick="exporter('pdf')">📄 PDF</button>
        <button class="btn bouton-export bouton-export-excel" type="button" onclick="exporter('xlsx')">📊 Excel</button>
    </div>
</div>
<div class="carte">
    <div class="entete-carte">
        <h2>Dépenses</h2>
        <div class="filtres">
            <select id="filtre-statut" class="champ-select">
                <option value="">Tous les statuts</option>
                <option value="brouillon">Brouillon</option>
                <option value="en_attente">En attente</option>
                <option value="valide">Validée</option>
                <option value="rejete">Rejetée</option>
                <option value="comptabilise">Comptabilisée</option>
            </select>
        </div>
    </div>
    <div class="table-wrapper">
        <table class="table">
            <thead>
                <tr>
                    <th>N°</th>
                    <th>Libellé</th>
                    <th>Catégorie</th>
                    <th>Chantier</th>
                    <th>Date</th>
                    <th>Montant</th>
                    <th>Statut</th>
                    <th></th>
                </tr>
            </thead>
            <tbody id="table-depenses"></tbody>
        </table>
    </div>
</div>
<?php
$contenu = ob_get_clean();

View::rendre('layouts.base', [
    'titre'   => $titre,
    'contenu' => $contenu,
    'scripts' => ['js/auth.js', 'js/format.js', 'js/depenses.js'],
]);
