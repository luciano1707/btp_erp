<?php
/**
 * @var string $titre
 * @var int|string|null $id
 * @var bool $peutValider
 * @var string|null $roleUtilisateur
 */
use App\Core\View;

ob_start();
?>
<div class="barre-actions">
    <a class="btn" href="<?= e(url('/depenses')) ?>">Retour à la liste</a>
</div>
<div class="carte">
    <div class="entete-carte">
        <h2>Détail de la dépense</h2>
        <div class="actions-groupe" id="actions-depense" data-peut-valider="<?= !empty($peutValider) ? '1' : '0' ?>" data-role="<?= e($roleUtilisateur ?? '') ?>"></div>
    </div>
    <div id="depense-detail">Chargement…</div>
</div>

<dialog id="dialog-rejet">
    <form method="dialog" class="dialog-form" id="form-rejet">
        <header class="dialog-entete">
            <h3>Rejeter la dépense</h3>
        </header>
        <label class="champ">
            <span>Motif du rejet</span>
            <textarea name="motif_rejet" required></textarea>
        </label>
        <footer class="dialog-pied">
            <button class="btn" value="annuler">Annuler</button>
            <button class="btn btn-rouge" value="valider">Rejeter</button>
        </footer>
    </form>
</dialog>
<?php
$contenu = ob_get_clean();

View::rendre('layouts.base', [
    'titre'   => $titre,
    'contenu' => $contenu,
    'scripts' => ['js/auth.js', 'js/format.js', 'js/depenses.js'],
]);
