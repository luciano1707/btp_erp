<?php
/**
 * @var string $titre
 */
use App\Core\View;

ob_start();
?>
<div class="barre-actions">
    <a class="btn" href="<?= e(url('/depenses')) ?>">Retour à la liste</a>
</div>
<div class="carte">
    <div class="entete-carte">
        <h2>Nouvelle dépense</h2>
    </div>
    <form id="form-depense" novalidate>
        <div class="grille-form">
            <label class="champ">
                <span>Libellé</span>
                <input type="text" name="libelle" maxlength="150" required>
            </label>
            <label class="champ">
                <span>Catégorie</span>
                <select name="categorie" required>
                    <option value="">Choisir…</option>
                    <option value="materiaux">Matériaux</option>
                    <option value="main_oeuvre">Main d'œuvre</option>
                    <option value="transport">Transport</option>
                    <option value="carburant">Carburant</option>
                    <option value="location">Location</option>
                    <option value="administratif">Administratif</option>
                    <option value="autre">Autre</option>
                </select>
            </label>
            <label class="champ">
                <span>Chantier</span>
                <select name="chantier_id" id="chantier_id"></select>
            </label>
            <label class="champ">
                <span>Date</span>
                <input type="date" name="date_depense" required>
            </label>
            <label class="champ">
                <span>Montant</span>
                <input type="number" name="montant" min="0" step="0.01" required>
            </label>
            <label class="champ">
                <span>Devise</span>
                <select name="devise">
                    <option value="MGA">MGA</option>
                    <option value="EUR">EUR</option>
                    <option value="USD">USD</option>
                </select>
            </label>
            <label class="champ">
                <span>Mode de paiement</span>
                <select name="mode_paiement">
                    <option value="">Non précisé</option>
                    <option value="especes">Espèces</option>
                    <option value="virement">Virement</option>
                    <option value="mobile_money">Mobile money</option>
                    <option value="cheque">Chèque</option>
                </select>
            </label>
            <label class="champ">
                <span>Bénéficiaire</span>
                <input type="text" name="beneficiaire" maxlength="150">
            </label>
        </div>
        <label class="champ">
            <span>Justificatif (référence)</span>
            <input type="text" name="justificatif" maxlength="255">
        </label>
        <label class="champ">
            <span>Notes</span>
            <textarea name="notes" rows="3"></textarea>
        </label>
        <div class="actions-form">
            <button class="btn btn-primaire" type="submit">Enregistrer la dépense</button>
        </div>
    </form>
</div>
<?php
$contenu = ob_get_clean();

View::rendre('layouts.base', [
    'titre'   => $titre,
    'contenu' => $contenu,
    'scripts' => ['js/auth.js', 'js/format.js', 'js/depenses.js'],
]);
