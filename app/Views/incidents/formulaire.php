<?php
/**
 * @var string $titre
 */
use App\Core\View;

ob_start();
?>
<div class="barre-actions">
    <a class="btn" href="<?= e(url('/incidents')) ?>">Retour à la liste</a>
</div>
<div class="carte">
    <div class="entete-carte">
        <h2>Déclarer un incident</h2>
    </div>
    <form id="form-incident" novalidate>
        <div class="grille-form">
            <label class="champ">
                <span>Chantier</span>
                <select name="chantier_id" id="chantier_id" required></select>
            </label>
            <label class="champ">
                <span>Date et heure</span>
                <input type="datetime-local" name="date_incident" required>
            </label>
            <label class="champ">
                <span>Lieu</span>
                <input type="text" name="lieu" maxlength="150">
            </label>
            <label class="champ">
                <span>Type</span>
                <select name="type_incident">
                    <option value="incident">Incident</option>
                    <option value="accident">Accident</option>
                    <option value="presque_accident">Presque accident</option>
                </select>
            </label>
            <label class="champ">
                <span>Gravité</span>
                <select name="gravite">
                    <option value="faible">Faible</option>
                    <option value="moyenne">Moyenne</option>
                    <option value="grave">Grave</option>
                    <option value="critique">Critique</option>
                </select>
            </label>
            <label class="champ">
                <span>Victimes</span>
                <input type="text" name="victimes" maxlength="255" placeholder="Noms / nombre">
            </label>
        </div>
        <label class="champ">
            <span>Description</span>
            <textarea name="description" rows="4" required></textarea>
        </label>
        <label class="champ">
            <span>Premiers secours</span>
            <textarea name="premiers_secours" rows="2"></textarea>
        </label>
        <label class="champ">
            <span>Action corrective</span>
            <textarea name="action_corrective" rows="2"></textarea>
        </label>
        <div class="actions-form">
            <button class="btn btn-primaire" type="submit">Enregistrer l'incident</button>
        </div>
    </form>
</div>
<?php
$contenu = ob_get_clean();

View::rendre('layouts.base', [
    'titre'   => $titre,
    'contenu' => $contenu,
    'scripts' => ['js/auth.js', 'js/format.js', 'js/incidents.js'],
]);
