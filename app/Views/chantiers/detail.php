<?php
/**
 * Detail d'un chantier : informations, statistiques d'avancement, gestion des lots.
 * @var string $titre
 * @var int $id
 * @var bool $peutGererLots
 * @var bool $peutVoirFinances
 * @var bool $peutSupprimerChantier
 */

use App\Core\View;

ob_start();
?>
<section class="entete-liste">
    <div>
        <h1 id="titre-chantier">Chargement&hellip;</h1>
        <p class="sous-titre" id="sous-titre-chantier"></p>
    </div>
    <div class="actions-entete">
        <a class="bouton bouton-secondaire" href="<?= e(url('/chantiers')) ?>">&larr; Liste</a>
        <a class="bouton bouton-secondaire" id="lien-pointage" href="#">Feuille de pointage</a>
        <?php if ($peutGererLots): ?>
            <a class="bouton bouton-primaire" id="lien-modifier" href="#">Modifier</a>
        <?php endif; ?>
        <?php if ($peutSupprimerChantier): ?>
            <button class="bouton bouton-danger" id="btn-supprimer-chantier" type="button">Supprimer</button>
        <?php endif; ?>
    </div>
</section>

<div id="zone-chantier" hidden>
    <section class="cartes">
        <article class="carte">
            <h2>Informations</h2>
            <dl class="profil" id="infos-chantier"></dl>
        </article>
        <?php if ($peutVoirFinances): ?>
        <article class="carte">
            <h2>Avancement global</h2>
            <div class="jauge-grande">
                <div class="jauge"><div class="jauge-remplie" id="jauge-globale"></div></div>
                <span class="jauge-valeur" id="avancement-valeur">0 %</span>
            </div>
            <dl class="profil">
                <dt>Budget previsionnel</dt><dd id="stat-budget-prev">—</dd>
                <dt>Total budgets lots</dt><dd id="stat-budget-lots">—</dd>
                <dt>Nombre de lots</dt><dd id="stat-nb-lots">—</dd>
                <dt>Cout main d'&oelig;uvre</dt><dd id="stat-cout-mo">—</dd>
                <dt>Cout materiaux</dt><dd id="stat-cout-mat">—</dd>
                <dt>Cout total engage</dt><dd id="stat-cout-total">—</dd>
                <dt>Reste sur budget</dt><dd id="stat-reste">—</dd>
            </dl>
        </article>
        <?php endif; ?>
        <?php if ($peutVoirFinances): ?>
        <article class="carte">
            <h2>R&eacute;partition des co&ucirc;ts</h2>
            <div id="donut-couts"><p class="chargement">Chargement&hellip;</p></div>
        </article>
        <?php endif; ?>
    </section>

    <section class="bloc-lots">
        <div class="entete-liste">
            <h2>Lots</h2>
            <?php if ($peutGererLots): ?>
                <button class="bouton bouton-primaire" id="btn-ajouter-lot" type="button">+ Ajouter un lot</button>
            <?php endif; ?>
        </div>

        <?php if ($peutGererLots): ?>
        <form id="form-lot" class="carte formulaire-lot" hidden>
            <input type="hidden" id="lot-id">
            <div class="grille-lot">
                <div class="champ"><label for="lot-nom">Nom du lot *</label><input type="text" id="lot-nom" required></div>
                <div class="champ"><label for="lot-budget">Budget (Ar)</label><input type="number" id="lot-budget" min="0" inputmode="numeric"></div>
                <div class="champ"><label for="lot-avancement">Avancement (%)</label><input type="number" id="lot-avancement" min="0" max="100" value="0"></div>
                <div class="champ"><label for="lot-statut">Statut</label>
                    <select id="lot-statut">
                        <option value="a_faire">A faire</option>
                        <option value="en_cours">En cours</option>
                        <option value="termine">Termine</option>
                    </select>
                </div>
            </div>
            <div id="lot-erreur" class="message-erreur" hidden></div>
            <div class="actions-form">
                <button type="submit" class="bouton bouton-primaire" id="btn-enregistrer-lot">Enregistrer le lot</button>
                <button type="button" class="bouton bouton-secondaire" id="btn-annuler-lot">Annuler</button>
            </div>
        </form>
        <?php endif; ?>

        <div class="tableau-enveloppe">
            <table class="tableau">
                <thead>
                    <tr><th>Lot</th><?php if ($peutVoirFinances): ?><th>Budget</th><?php endif; ?><th>Avancement</th><th>Statut</th><?php if ($peutGererLots): ?><th class="col-actions">Actions</th><?php endif; ?></tr>
                </thead>
                <tbody id="corps-lots"><tr><td class="vide" colspan="<?= (int) $peutGererLots + (int) $peutVoirFinances + 3 ?>">Chargement&hellip;</td></tr></tbody>
            </table>
        </div>
    </section>
</div>
<?php
$contenu = ob_get_clean();

View::rendre('layouts.base', [
    'titre'       => $titre,
    'contenu'     => $contenu,
    'scripts'     => ['js/auth.js', 'js/format.js', 'js/charts.js', 'js/chantier-detail.js'],
    'config_json' => [
        'id' => $id,
        'peutGererLots' => $peutGererLots,
        'peutVoirFinances' => $peutVoirFinances,
        'peutSupprimerChantier' => $peutSupprimerChantier,
    ],
]);
