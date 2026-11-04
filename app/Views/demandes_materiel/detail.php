<?php
/**
 * @var string $titre
 * @var int|string|null $id
 * @var bool $peutValider
 * @var bool $peutTraiter
 * @var bool $peutModifier
 */
use App\Core\View;

ob_start();
?>
<div class="barre-actions">
    <a class="btn" href="<?= e(url('/demandes-materiel')) ?>">Retour à la liste</a>
    <?php if (!empty($peutModifier)): ?><a class="btn btn-primaire" id="btn-modifier" href="<?= e(url('/demandes-materiel/' . $id . '/modifier')) ?>">Modifier</a><?php endif; ?>
</div>
<div class="carte">
    <div class="entete-carte">
        <h2>Détail de la demande</h2>
        <div class="actions-groupe" id="actions-demande" data-peut-valider="<?= !empty($peutValider) ? '1' : '0' ?>" data-peut-traiter="<?= !empty($peutTraiter) ? '1' : '0' ?>" data-peut-modifier="<?= !empty($peutModifier) ? '1' : '0' ?>"></div>
    </div>
    <div class="grille-info">
        <div><span class="info-label">N°</span><div id="dm-numero"></div></div>
        <div><span class="info-label">Objet</span><div id="dm-objet"></div></div>
        <div><span class="info-label">Chantier</span><div id="dm-chantier"></div></div>
        <div><span class="info-label">Demandeur</span><div id="dm-demandeur"></div></div>
        <div><span class="info-label">Urgence</span><div id="dm-urgence"></div></div>
        <div><span class="info-label">Statut</span><div id="dm-statut"></div></div>
        <div><span class="info-label">Date</span><div id="dm-date"></div></div>
    </div>
    <div class="entete-carte" style="margin-top:16px">
        <h3>Lignes</h3>
    </div>
    <div class="table-wrapper">
        <table class="table">
            <thead>
                <tr>
                    <th>Désignation</th>
                    <th>Unité</th>
                    <th>Quantité demandée</th>
                </tr>
            </thead>
            <tbody id="dm-lignes"></tbody>
        </table>
    </div>
    <div class="bloc-note" id="bloc-refus" hidden>
        <h4>Motif du refus</h4>
        <p id="dm-motif-refus"></p>
    </div>
</div>

<dialog id="dialog-refus">
    <form method="dialog" class="dialog-form" id="form-refus">
        <header class="dialog-entete">
            <h3>Refuser la demande</h3>
        </header>
        <label class="champ">
            <span>Motif du refus</span>
            <textarea name="motif_refus" required></textarea>
        </label>
        <footer class="dialog-pied">
            <button class="btn" value="annuler">Annuler</button>
            <button class="btn btn-rouge" value="valider">Refuser</button>
        </footer>
    </form>
</dialog>
<?php
$contenu = ob_get_clean();

View::rendre('layouts.base', [
    'titre'   => $titre,
    'contenu' => $contenu,
    'scripts' => ['js/auth.js', 'js/format.js', 'js/demandes-materiel-detail.js'],
]);
