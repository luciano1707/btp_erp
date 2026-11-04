<?php
/**
 * @var string $titre
 * @var int|null $id
 */
use App\Core\View;

ob_start();
?>
<div class="barre-actions">
    <a class="btn" href="<?= e(url('/budgets')) ?>">Retour à la liste</a>
</div>
<div class="carte">
    <div class="entete-carte">
        <h2><?= e($titre) ?></h2>
    </div>
    <form id="form-budget" novalidate>
        <input type="hidden" name="id" id="budget_id" value="<?= e($id ?? '') ?>">
        <div class="grille-form">
            <label class="champ">
                <span>Chantier</span>
                <select name="chantier_id" id="chantier_id" required></select>
            </label>
            <label class="champ">
                <span>Année</span>
                <input type="number" name="annee" id="annee" min="2000" max="2100" step="1" required>
            </label>
            <label class="champ">
                <span>Budget révisé</span>
                <input type="number" name="budget_revision" id="budget_revision" min="0" step="0.01" value="0">
            </label>
            <label class="champ">
                <span>Devise</span>
                <select name="devise" id="devise">
                    <option value="MGA">MGA</option>
                    <option value="EUR">EUR</option>
                    <option value="USD">USD</option>
                </select>
            </label>
            <label class="champ">
                <span>Statut</span>
                <select name="statut" id="statut">
                    <option value="ouvert">Ouvert</option>
                    <option value="cloture">Clôturé</option>
                </select>
            </label>
        </div>
        <label class="champ">
            <span>Notes</span>
            <textarea name="notes" id="notes" rows="2"></textarea>
        </label>

        <div class="entete-carte" style="margin-top:16px">
            <h3>Lignes budgétaires</h3>
            <button class="btn" type="button" id="ajouter-ligne">Ajouter une ligne</button>
        </div>
        <div class="table-wrapper">
            <table class="table">
                <thead>
                    <tr>
                        <th>Rubrique</th>
                        <th>Prévu</th>
                        <th>Engagé</th>
                        <th>Réel</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody id="lignes-budget"></tbody>
            </table>
        </div>
        <p class="sous-titre" id="total-budget">Total prévu : 0 Ar</p>
        <div class="actions-form">
            <button class="btn btn-primaire" type="submit">Enregistrer le budget</button>
        </div>
    </form>
</div>
<?php
$contenu = ob_get_clean();

View::rendre('layouts.base', [
    'titre'   => $titre,
    'contenu' => $contenu,
    'scripts' => ['js/auth.js', 'js/format.js', 'js/budgets.js'],
    'config_json' => [
        'id' => $id,
    ],
]);
