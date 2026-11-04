<?php
/**
 * @var string $titre
 * @var bool $peutCreer
 */
use App\Core\View;

ob_start();
?>
<div class="barre-actions">
    <?php if (!empty($peutCreer)): ?><a class="btn btn-primaire" href="<?= e(url('/rfi/nouveau')) ?>">Nouvelle RFI</a><?php endif; ?>
</div>
<div class="carte">
    <div class="entete-carte">
        <h2>Demandes d'information (RFI)</h2>
        <div class="filtres">
            <select id="filtre-statut" class="champ-select">
                <option value="">Tous les statuts</option>
                <option value="ouvert">Ouvert</option>
                <option value="en_cours">En cours</option>
                <option value="repondu">Répondu</option>
                <option value="cloture">Clôturé</option>
                <option value="annule">Annulé</option>
            </select>
            <select id="filtre-priorite" class="champ-select">
                <option value="">Toutes les priorités</option>
                <option value="basse">Basse</option>
                <option value="normale">Normale</option>
                <option value="haute">Haute</option>
                <option value="critique">Critique</option>
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
                    <th>Émetteur</th>
                    <th>Priorité</th>
                    <th>Statut</th>
                    <th>Date limite</th>
                    <th></th>
                </tr>
            </thead>
            <tbody id="table-rfi"></tbody>
        </table>
    </div>
</div>
<?php
$contenu = ob_get_clean();

View::rendre('layouts.base', [
    'titre'   => $titre,
    'contenu' => $contenu,
    'scripts' => ['js/auth.js', 'js/format.js', 'js/rfi.js'],
]);
