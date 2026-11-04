<?php
/**
 * @var string $titre
 * @var bool $peutCreer
 * @var bool $peutModifier
 */
use App\Core\View;

ob_start();
?>
<div class="barre-actions">
    <?php if (!empty($peutCreer)): ?><a class="btn btn-primaire" href="<?= e(url('/rapports-journaliers/nouveau')) ?>">Nouveau rapport</a><?php endif; ?>
    <div class="groupe-export">
        <button class="btn bouton-export" type="button" onclick="exporter('pdf')">📄 PDF</button>
        <button class="btn bouton-export bouton-export-excel" type="button" onclick="exporter('xlsx')">📊 Excel</button>
    </div>
</div>
<div class="carte">
    <div class="entete-carte">
        <h2>Rapports journaliers</h2>
        <div class="filtres">
            <select id="filtre-statut" class="champ-select">
                <option value="">Tous les statuts</option>
                <option value="brouillon">Brouillon</option>
                <option value="soumis">Soumis</option>
                <option value="consulte">Consulté</option>
                <option value="archive">Archivé</option>
            </select>
        </div>
    </div>
    <div class="table-wrapper">
        <table class="table">
            <thead>
                <tr>
                    <th>N°</th>
                    <th>Chantier</th>
                    <th>Date</th>
                    <th>Chef de chantier</th>
                    <th>Avancement</th>
                    <th>Statut</th>
                    <?php if (!empty($peutModifier)): ?><th class="col-actions">Actions</th><?php endif; ?>
                </tr>
            </thead>
            <tbody id="table-rapports"></tbody>
        </table>
    </div>
</div>
<?php
$contenu = ob_get_clean();

View::rendre('layouts.base', [
    'titre'   => $titre,
    'contenu' => $contenu,
    'scripts' => ['js/auth.js', 'js/format.js', 'js/rapports-journaliers-liste.js'],
    'config_json' => [
        'peutModifier' => !empty($peutModifier),
    ],
]);
