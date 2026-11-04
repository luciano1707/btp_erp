<?php
/**
 * @var string $titre
 */
use App\Core\View;

ob_start();
?>
<div class="barre-actions">
    <a class="btn" href="<?= e(url('/qualite')) ?>">Retour à la liste</a>
</div>
<div class="carte">
    <div class="entete-carte">
        <h2>Nouvelle inspection qualité</h2>
    </div>
    <form id="form-qualite" novalidate>
        <div class="grille-form">
            <label class="champ">
                <span>Chantier</span>
                <select name="chantier_id" id="chantier_id" required></select>
            </label>
            <label class="champ">
                <span>Lot</span>
                <select name="lot_id" id="lot_id"></select>
            </label>
            <label class="champ">
                <span>Date</span>
                <input type="date" name="date_inspection" required>
            </label>
            <label class="champ">
                <span>Type d'inspection</span>
                <select name="type_inspection">
                    <option value="">Non précisé</option>
                    <option value="reception">Réception</option>
                    <option value="controle">Contrôle</option>
                    <option value="essai">Essai</option>
                    <option value="audit">Audit</option>
                    <option value="autre">Autre</option>
                </select>
            </label>
            <label class="champ">
                <span>Résultat</span>
                <select name="resultat">
                    <option value="conforme">Conforme</option>
                    <option value="non_conforme">Non conforme</option>
                    <option value="reserve">Réserve</option>
                </select>
            </label>
        </div>
        <label class="champ">
            <span>Constat</span>
            <textarea name="constat" rows="3"></textarea>
        </label>
        <label class="champ">
            <span>Action corrective</span>
            <textarea name="action_corrective" rows="3"></textarea>
        </label>
        <div class="actions-form">
            <button class="btn btn-primaire" type="submit">Enregistrer l'inspection</button>
        </div>
    </form>
</div>
<?php
$contenu = ob_get_clean();

View::rendre('layouts.base', [
    'titre'   => $titre,
    'contenu' => $contenu,
    'scripts' => ['js/auth.js', 'js/format.js', 'js/qualite.js'],
]);
