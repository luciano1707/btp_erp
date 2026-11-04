<?php
/**
 * @var string $titre
 * @var int|null $id
 */
use App\Core\View;

ob_start();
?>
<div class="barre-actions">
    <a class="btn" href="<?= e(url('/rapports-journaliers')) ?>">Retour à la liste</a>
</div>
<div class="carte">
    <div class="entete-carte">
        <h2><?= e($titre) ?></h2>
    </div>
    <form id="form-rapport" class="form-grille">
        <input type="hidden" id="rapport_id" name="id" value="<?= e($id ?? '') ?>">
        <div class="champ">
            <label for="chantier_id">Chantier</label>
            <select id="chantier_id" name="chantier_id" required></select>
        </div>
        <div class="champ">
            <label for="date_rapport">Date</label>
            <input id="date_rapport" name="date_rapport" type="date" required>
        </div>
        <div class="champ">
            <label for="meteo">Météo</label>
            <input id="meteo" name="meteo" type="text" placeholder="Ensoleillé, pluie...">
        </div>
        <div class="champ">
            <label for="avancement_pct">Avancement (%)</label>
            <input id="avancement_pct" name="avancement_pct" type="number" min="0" max="100" step="1">
        </div>
        <div class="champ champ-large">
            <label for="travaux_effectues">Travaux effectués</label>
            <textarea id="travaux_effectues" name="travaux_effectues" rows="3"></textarea>
        </div>
        <div class="champ champ-large">
            <label for="problemes">Problèmes rencontrés</label>
            <textarea id="problemes" name="problemes" rows="2"></textarea>
        </div>
        <div class="champ champ-large">
            <label for="observations">Observations</label>
            <textarea id="observations" name="observations" rows="2"></textarea>
        </div>
        <div class="form-actions">
            <button class="btn btn-primaire" type="submit">Enregistrer</button>
        </div>
    </form>
</div>
<?php
$contenu = ob_get_clean();

View::rendre('layouts.base', [
    'titre'   => $titre,
    'contenu' => $contenu,
    'scripts' => ['js/auth.js', 'js/format.js', 'js/rapports-journaliers-form.js'],
    'config_json' => [
        'id' => $id,
    ],
]);
