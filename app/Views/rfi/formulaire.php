<?php
/**
 * @var string $titre
 */
use App\Core\View;

ob_start();
?>
<div class="barre-actions">
    <a class="btn" href="<?= e(url('/rfi')) ?>">Retour à la liste</a>
</div>
<div class="carte">
    <div class="entete-carte">
        <h2>Nouvelle RFI</h2>
    </div>
    <form id="form-rfi" novalidate>
        <div class="grille-form">
            <label class="champ">
                <span>Chantier</span>
                <select name="chantier_id" id="chantier_id" required></select>
            </label>
            <label class="champ">
                <span>Objet</span>
                <input type="text" name="objet" maxlength="150" required>
            </label>
            <label class="champ">
                <span>Priorité</span>
                <select name="priorite">
                    <option value="basse">Basse</option>
                    <option value="normale" selected>Normale</option>
                    <option value="haute">Haute</option>
                    <option value="critique">Critique</option>
                </select>
            </label>
            <label class="champ">
                <span>Date limite de réponse</span>
                <input type="date" name="date_limite">
            </label>
        </div>
        <label class="champ">
            <span>Question</span>
            <textarea name="question" rows="6" required></textarea>
        </label>
        <div class="actions-form">
            <button class="btn btn-primaire" type="submit">Enregistrer la RFI</button>
        </div>
    </form>
</div>
<?php
$contenu = ob_get_clean();

View::rendre('layouts.base', [
    'titre'   => $titre,
    'contenu' => $contenu,
    'scripts' => ['js/auth.js', 'js/format.js', 'js/rfi.js'],
]);
