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
    <a class="btn" href="<?= e(url('/securite')) ?>">Retour à la liste</a>
</div>
<div class="carte">
    <div class="entete-carte">
        <h2>Détail de l'observation</h2>
        <div class="actions-groupe" id="actions-securite" data-peut-modifier="<?= !empty($peutModifier) ? '1' : '0' ?>"></div>
    </div>
    <div id="securite-detail">Chargement…</div>
</div>

<dialog id="dialog-securite">
    <form method="dialog" class="dialog-form" id="form-maj-securite">
        <header class="dialog-entete">
            <h3>Mettre à jour l'observation</h3>
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
            <span>Action immédiate</span>
            <textarea name="action_immediate" rows="3"></textarea>
        </label>
        <label class="champ">
            <span>Mesure préventive</span>
            <textarea name="mesure_preventive" rows="3"></textarea>
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
    'scripts' => ['js/auth.js', 'js/format.js', 'js/securite.js'],
]);
