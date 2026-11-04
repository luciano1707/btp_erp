<?php
/**
 * @var string $titre
 * @var int|string|null $id
 * @var bool $peutModifier
 */
use App\Core\View;

ob_start();
?>
<div class="barre-actions">
    <a class="btn" href="<?= e(url('/qualite')) ?>">Retour à la liste</a>
</div>
<div class="carte">
    <div class="entete-carte">
        <h2>Détail de l'inspection</h2>
        <div class="actions-groupe" id="actions-qualite" data-peut-modifier="<?= !empty($peutModifier) ? '1' : '0' ?>"></div>
    </div>
    <div id="qualite-detail">Chargement…</div>
</div>

<dialog id="dialog-qualite">
    <form method="dialog" class="dialog-form" id="form-maj-qualite">
        <header class="dialog-entete">
            <h3>Mettre à jour l'inspection</h3>
        </header>
        <label class="champ">
            <span>Statut</span>
            <select name="statut">
                <option value="ouvert">Ouvert</option>
                <option value="en_cours">En cours</option>
                <option value="clos">Clos</option>
            </select>
        </label>
        <label class="champ">
            <span>Action corrective</span>
            <textarea name="action_corrective" rows="4"></textarea>
        </label>
        <footer class="dialog-pied">
            <button class="btn" value="annuler">Annuler</button>
            <button class="btn btn-primaire" value="valider">Enregistrer</button>
        </footer>
    </form>
</dialog>
<?php
$contenu = ob_get_clean();

View::rendre('layouts.base', [
    'titre'   => $titre,
    'contenu' => $contenu,
    'scripts' => ['js/auth.js', 'js/format.js', 'js/qualite.js'],
]);
