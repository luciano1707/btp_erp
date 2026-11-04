<?php
/**
 * @var string $titre
 * @var bool $peutCreer
 */
use App\Core\View;

ob_start();
?>
<div class="barre-actions">
    <?php if (!empty($peutCreer)): ?><a class="btn btn-primaire" href="<?= e(url('/budgets/nouveau')) ?>">Nouveau budget</a><?php endif; ?>
    <div class="groupe-export">
        <button class="btn bouton-export" type="button" onclick="exporter('pdf')">📄 PDF</button>
        <button class="btn bouton-export bouton-export-excel" type="button" onclick="exporter('xlsx')">📊 Excel</button>
    </div>
</div>

<!-- KPI Dashboard -->
<div class="cartes" id="kpi-budgets" style="margin-bottom: 24px;">
    <article class="carte">
        <h3>Budget total</h3>
        <p class="kpi-valeur" id="kpi-total">0 Ar</p>
    </article>
    <article class="carte">
        <h3>Dépensé</h3>
        <p class="kpi-valeur" id="kpi-depense">0 Ar</p>
    </article>
    <article class="carte">
        <h3>Restant</h3>
        <p class="kpi-valeur" id="kpi-restant">0 Ar</p>
    </article>
    <article class="carte">
        <h3>% Consommé</h3>
        <p class="kpi-valeur" id="kpi-pourcentage">0%</p>
    </article>
</div>

<div class="carte">
    <div class="entete-carte">
        <h2>Budgets</h2>
        <div class="filtres">
            <select id="filtre-chantier" class="champ-select">
                <option value="">Tous les chantiers</option>
            </select>
            <select id="filtre-annee" class="champ-select">
                <option value="">Toutes les années</option>
            </select>
            <select id="filtre-statut" class="champ-select">
                <option value="">Tous les statuts</option>
                <option value="ouvert">Ouvert</option>
                <option value="cloture">Clôturé</option>
            </select>
        </div>
    </div>
    <div class="table-wrapper">
        <table class="table">
            <thead>
                <tr>
                    <th>Chantier</th>
                    <th>Année</th>
                    <th>Prévisionnel</th>
                    <th>Engagé</th>
                    <th>Réel</th>
                    <th>Dépenses validées</th>
                    <th>Restant</th>
                    <th>% Consommé</th>
                    <th>Progression</th>
                    <th>Statut</th>
                    <th></th>
                </tr>
            </thead>
            <tbody id="table-budgets"></tbody>
        </table>
    </div>
</div>
<?php
$contenu = ob_get_clean();

View::rendre('layouts.base', [
    'titre'   => $titre,
    'contenu' => $contenu,
    'scripts' => ['js/auth.js', 'js/format.js', 'js/budgets.js'],
    'config_json' => [
        'peutCreer' => !empty($peutCreer),
    ],
]);
