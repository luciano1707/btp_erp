<?php
/**
 * Formulaire chantier (creation / edition).
 * @var string $titre
 * @var int|null $id
 * @var array<string,string> $types
 * @var array<string,string> $statuts
 * @var string[] $champsAutorises
 */

use App\Core\View;

ob_start();
?>
<section class="entete-liste"><h1><?= e($titre) ?></h1></section>

<form id="form-chantier" class="formulaire formulaire-large carte">
    <?php if (in_array('code', $champsAutorises, true)): ?><div class="champ">
        <label for="code">Code</label>
        <input type="text" id="code" name="code" placeholder="CH-2026-001">
    </div><?php endif; ?>
    <?php if (in_array('nom', $champsAutorises, true)): ?><div class="champ">
        <label for="nom">Nom du chantier *</label>
        <input type="text" id="nom" name="nom" required>
    </div><?php endif; ?>
    <?php if (in_array('type', $champsAutorises, true) || in_array('statut', $champsAutorises, true)): ?>
    <div class="grille-2">
        <?php if (in_array('type', $champsAutorises, true)): ?>
        <div class="champ">
            <label for="type">Type</label>
            <select id="type" name="type">
                <?php foreach ($types as $val => $lib): ?>
                    <option value="<?= e($val) ?>"><?= e($lib) ?></option>
                <?php endforeach; ?>
            </select>
        </div>
        <?php endif; ?>
        <?php if (in_array('statut', $champsAutorises, true)): ?>
        <div class="champ">
            <label for="statut">Statut</label>
            <select id="statut" name="statut">
                <?php foreach ($statuts as $val => $lib): ?>
                    <option value="<?= e($val) ?>"><?= e($lib) ?></option>
                <?php endforeach; ?>
            </select>
        </div>
        <?php endif; ?>
    </div>
    <?php endif; ?>
    <?php if (in_array('client_id', $champsAutorises, true) || in_array('responsable_id', $champsAutorises, true)): ?>
    <div class="grille-2">
        <?php if (in_array('client_id', $champsAutorises, true)): ?>
        <div class="champ">
            <label for="client_id">Client</label>
            <select id="client_id" name="client_id"><option value="">— Aucun —</option></select>
        </div>
        <?php endif; ?>
        <?php if (in_array('responsable_id', $champsAutorises, true)): ?>
        <div class="champ">
            <label for="responsable_id">Responsable (chef de chantier)</label>
            <select id="responsable_id" name="responsable_id"><option value="">— Aucun —</option></select>
        </div>
        <?php endif; ?>
    </div>
    <?php endif; ?>
    <?php if (in_array('localisation', $champsAutorises, true)): ?>
    <div class="champ">
        <label for="localisation">Localisation</label>
        <input type="text" id="localisation" name="localisation" placeholder="Mahajanga">
    </div>
    <?php endif; ?>
    <?php if (in_array('date_debut', $champsAutorises, true) || in_array('date_fin_prevue', $champsAutorises, true) || in_array('date_fin_reelle', $champsAutorises, true)): ?>
    <div class="grille-2">
        <?php if (in_array('date_debut', $champsAutorises, true)): ?>
        <div class="champ">
            <label for="date_debut">Date de debut</label>
            <input type="date" id="date_debut" name="date_debut">
        </div>
        <?php endif; ?>
        <?php if (in_array('date_fin_prevue', $champsAutorises, true)): ?>
        <div class="champ">
            <label for="date_fin_prevue">Fin prevue</label>
            <input type="date" id="date_fin_prevue" name="date_fin_prevue">
        </div>
        <?php endif; ?>
        <?php if (in_array('date_fin_reelle', $champsAutorises, true)): ?>
        <div class="champ">
            <label for="date_fin_reelle">Date de fin réelle</label>
            <input type="date" id="date_fin_reelle" name="date_fin_reelle">
        </div>
        <?php endif; ?>
    </div>
    <?php endif; ?>
    <?php if (in_array('budget_previsionnel', $champsAutorises, true)): ?>
    <div class="champ">
        <label for="budget_previsionnel">Budget previsionnel (Ar)</label>
        <input type="number" id="budget_previsionnel" name="budget_previsionnel" inputmode="numeric" min="0">
    </div>
    <?php endif; ?>
    <?php if (in_array('description', $champsAutorises, true)): ?>
    <div class="champ">
        <label for="description">Description</label>
        <textarea id="description" name="description" rows="3"></textarea>
    </div>
    <?php endif; ?>

    <div id="message-erreur" class="message-erreur" hidden></div>

    <div class="actions-form">
        <button type="submit" id="btn-enregistrer" class="bouton bouton-primaire">Enregistrer</button>
        <a class="bouton bouton-secondaire" href="<?= e(url('/chantiers')) ?>">Annuler</a>
    </div>
</form>
<?php
$contenu = ob_get_clean();

View::rendre('layouts.base', [
    'titre'       => $titre,
    'contenu'     => $contenu,
    'scripts'     => ['js/auth.js', 'js/format.js', 'js/chantier-form.js'],
    'config_json' => ['id' => $id, 'champs' => $champsAutorises],
]);
