<?php
/**
 * @var string $titre
 * @var bool $peutCreer
 */
use App\Core\View;

ob_start();
?>
<div class="barre-actions">
    <?php if (!empty($peutCreer)): ?><a class="btn btn-primaire" href="<?= e(url('/incidents/nouveau')) ?>">Déclarer un incident</a><?php endif; ?>
</div>
<div class="carte">
    <div class="entete-carte">
        <h2>Incidents</h2>
        <div class="filtres">
            <select id="filtre-statut" class="champ-select">
                <option value="">Tous les statuts</option>
                <option value="ouvert">Ouvert</option>
                <option value="enquete">Enquête</option>
                <option value="clos">Clos</option>
            </select>
            <select id="filtre-gravite" class="champ-select">
                <option value="">Toutes les gravités</option>
                <option value="faible">Faible</option>
                <option value="moyenne">Moyenne</option>
                <option value="grave">Grave</option>
                <option value="critique">Critique</option>
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
                    <th>Type</th>
                    <th>Gravité</th>
                    <th>Statut</th>
                    <th></th>
                </tr>
            </thead>
            <tbody id="table-incidents"></tbody>
        </table>
    </div>
</div>
<?php
$contenu = ob_get_clean();

View::rendre('layouts.base', [
    'titre'   => $titre,
    'contenu' => $contenu,
    'scripts' => ['js/auth.js', 'js/format.js', 'js/incidents.js'],
]);
