<?php
/**
 * @var string $titre
 * @var int|null $id
 */
use App\Core\View;

ob_start();
?>
<div class="barre-actions">
    <a class="btn" href="<?= e(url('/demandes-materiel')) ?>">Retour à la liste</a>
</div>
<div class="carte">
    <div class="entete-carte">
        <h2><?= e($titre) ?></h2>
    </div>
    <form id="form-demande" novalidate>
        <input type="hidden" name="id" id="demande_id" value="<?= e($id ?? '') ?>">
        <div class="grille-form">
            <label class="champ">
                <span>Objet</span>
                <input type="text" name="objet" id="objet" required>
            </label>
            <label class="champ">
                <span>Chantier</span>
                <select name="chantier_id" id="select-chantier"></select>
            </label>
            <label class="champ">
                <span>Date de demande</span>
                <input type="date" name="date_demande" id="date_demande" required>
            </label>
            <label class="champ">
                <span>Urgence</span>
                <select name="urgence" id="urgence">
                    <option value="normale">Normale</option>
                    <option value="urgente">Urgente</option>
                    <option value="tres_urgente">Très urgente</option>
                </select>
            </label>
        </div>
        <label class="champ">
            <span>Notes</span>
            <textarea name="notes" id="notes" rows="3"></textarea>
        </label>
        <div class="entete-carte" style="margin-top:16px">
            <h3>Lignes de demande</h3>
            <button class="btn" type="button" id="ajouter-ligne">Ajouter une ligne</button>
        </div>
        <div class="table-wrapper">
            <table class="table">
                <thead>
                    <tr>
                        <th>Désignation</th>
                        <th>Unité</th>
                        <th>Quantité demandée</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody id="lignes-demande"></tbody>
            </table>
        </div>
        <div class="actions-form">
            <button class="btn btn-primaire" type="submit">Enregistrer la demande</button>
        </div>
    </form>
</div>
<?php
$contenu = ob_get_clean();

View::rendre('layouts.base', [
    'titre'   => $titre,
    'contenu' => $contenu,
    'scripts' => ['js/auth.js', 'js/format.js', 'js/demandes-materiel-form.js'],
    'config_json' => [
        'id' => $id,
    ],
]);
