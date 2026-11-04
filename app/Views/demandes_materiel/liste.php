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
    <?php if (!empty($peutCreer)): ?><a class="btn btn-primaire" href="<?= e(url('/demandes-materiel/nouveau')) ?>">Nouvelle demande</a><?php endif; ?>
    <div class="groupe-export">
        <button class="btn bouton-export" type="button" onclick="exporter('pdf')">📄 PDF</button>
        <button class="btn bouton-export bouton-export-excel" type="button" onclick="exporter('xlsx')">📊 Excel</button>
    </div>
</div>
<div class="carte">
    <div class="entete-carte">
        <h2>Liste des demandes de matériel</h2>
        <div class="filtres">
            <select id="filtre-statut" class="champ-select">
                <option value="">Tous les statuts</option>
                <option value="en_attente">En attente</option>
                <option value="valide">Validé</option>
                <option value="refuse">Refusé</option>
                <option value="traite">Traité</option>
                <option value="annule">Annulé</option>
            </select>
            <select id="filtre-urgence" class="champ-select">
                <option value="">Toutes les urgences</option>
                <option value="normale">Normale</option>
                <option value="urgente">Urgente</option>
                <option value="tres_urgente">Très urgente</option>
            </select>
        </div>
    </div>
    <div class="table-wrapper">
        <table class="table">
            <thead>
                <tr>
                    <th>N°</th>
                    <th>Objet</th>
                    <th>Chantier</th>
                    <th>Demandeur</th>
                    <th>Urgence</th>
                    <th>Statut</th>
                    <th>Date</th>
                    <?php if (!empty($peutModifier)): ?><th class="col-actions">Actions</th><?php endif; ?>
                </tr>
            </thead>
            <tbody id="table-demandes"></tbody>
        </table>
    </div>
</div>
<?php
$contenu = ob_get_clean();

View::rendre('layouts.base', [
    'titre'   => $titre,
    'contenu' => $contenu,
    'scripts' => ['js/auth.js', 'js/format.js', 'js/demandes-materiel-liste.js'],
    'config_json' => [
        'peutModifier' => !empty($peutModifier),
    ],
]);
