<?php
/**
 * @var string $titre
 * @var bool $peutCreer
 */
use App\Core\View;

ob_start();
?>
<div class="barre-actions">
    <?php if (!empty($peutCreer)): ?><a class="btn btn-primaire" href="<?= e(url('/qualite/nouveau')) ?>">Nouvelle inspection</a><?php endif; ?>
</div>
<div class="carte">
    <div class="entete-carte">
        <h2>Inspections qualité</h2>
        <div class="filtres">
            <select id="filtre-statut" class="champ-select">
                <option value="">Tous les statuts</option>
                <option value="ouvert">Ouvert</option>
                <option value="en_cours">En cours</option>
                <option value="clos">Clos</option>
            </select>
            <select id="filtre-resultat" class="champ-select">
                <option value="">Tous les résultats</option>
                <option value="conforme">Conforme</option>
                <option value="non_conforme">Non conforme</option>
                <option value="reserve">Réserve</option>
            </select>
        </div>
    </div>
    <div class="table-wrapper">
        <table class="table">
            <thead>
                <tr>
                    <th>N°</th>
                    <th>Chantier</th>
                    <th>Lot</th>
                    <th>Date</th>
                    <th>Type</th>
                    <th>Résultat</th>
                    <th>Statut</th>
                    <th></th>
                </tr>
            </thead>
            <tbody id="table-qualite"></tbody>
        </table>
    </div>
</div>
<?php
$contenu = ob_get_clean();

View::rendre('layouts.base', [
    'titre'   => $titre,
    'contenu' => $contenu,
    'scripts' => ['js/auth.js', 'js/format.js', 'js/qualite.js'],
]);
