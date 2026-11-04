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
    <a class="btn" href="<?= e(url('/incidents')) ?>">Retour à la liste</a>
</div>
<div class="carte">
    <div class="entete-carte">
        <h2>Détail de l'incident</h2>
        <div class="actions-groupe" id="actions-incident" data-peut-modifier="<?= !empty($peutModifier) ? '1' : '0' ?>"></div>
    </div>
    <div id="incident-detail">Chargement…</div>
</div>

<dialog id="dialog-incident">
    <form method="dialog" class="dialog-form" id="form-maj-incident">
        <header class="dialog-entete">
            <h3>Mettre à jour l'incident</h3>
        </header>
        <label class="champ">
            <span>Statut</span>
            <select name="statut">
                <option value="ouvert">Ouvert</option>
                <option value="enquete">Enquête</option>
                <option value="clos">Clos</option>
            </select>
        </label>
        <label class="champ">
            <span>Premiers secours</span>
            <textarea name="premiers_secours" rows="3"></textarea>
        </label>
        <label class="champ">
            <span>Action corrective</span>
            <textarea name="action_corrective" rows="3"></textarea>
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
    'scripts' => ['js/auth.js', 'js/format.js', 'js/incidents.js'],
]);
