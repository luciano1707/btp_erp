<?php
/**
 * @var string $titre
 */
use App\Core\View;

ob_start();
?>
<div class="barre-actions">
    <a class="btn" href="<?= e(url('/securite')) ?>">Retour à la liste</a>
</div>
<div class="carte">
    <div class="entete-carte">
        <h2>Nouvelle observation sécurité</h2>
    </div>
    <form id="form-securite" novalidate>
        <div class="grille-form">
            <label class="champ">
                <span>Chantier</span>
                <select name="chantier_id" id="chantier_id" required></select>
            </label>
            <label class="champ">
                <span>Date</span>
                <input type="date" name="date_observation" required>
            </label>
            <label class="champ">
                <span>Lieu</span>
                <input type="text" name="lieu" maxlength="150" placeholder="Zone, atelier, étage…">
            </label>
            <label class="champ">
                <span>Type</span>
                <select name="type_observation">
                    <option value="danger">Danger</option>
                    <option value="risque">Risque</option>
                    <option value="bonne_pratique">Bonne pratique</option>
                    <option value="autre">Autre</option>
                </select>
            </label>
        </div>
        <label class="champ">
            <span>Description</span>
            <textarea name="description" rows="4" required></textarea>
        </label>
        <label class="champ">
            <span>Action immédiate</span>
            <textarea name="action_immediate" rows="2"></textarea>
        </label>
        <label class="champ">
            <span>Mesure préventive</span>
            <textarea name="mesure_preventive" rows="2"></textarea>
        </label>
        <div class="actions-form">
            <button class="btn btn-primaire" type="submit">Enregistrer l'observation</button>
        </div>
    </form>
</div>
<?php
$contenu = ob_get_clean();

View::rendre('layouts.base', [
    'titre'   => $titre,
    'contenu' => $contenu,
    'scripts' => ['js/auth.js', 'js/format.js', 'js/securite.js'],
]);
