<?php
/**
 * Feuille de pointage journaliere d'un chantier.
 * @var string $titre
 * @var int $id
 * @var bool $peutModifier
 * @var bool $peutVoirCout
 */

use App\Core\View;

ob_start();
?>
<section class="entete-liste">
    <div>
        <h1>Feuille de pointage <span class="mg">&middot; Takelaka fanamarihana</span></h1>
        <p class="sous-titre" id="sous-titre-chantier">Chargement&hellip;</p>
    </div>
    <a class="bouton bouton-secondaire" id="lien-retour" href="#">&larr; Retour au chantier</a>
</section>

<div class="carte barre-pointage">
    <div class="champ">
        <label for="date-pointage">Date</label>
        <input type="date" id="date-pointage">
    </div>
    <?php if ($peutVoirCout): ?><p class="sous-titre" id="total-jour">&nbsp;</p><?php endif; ?>
</div>

<div class="tableau-enveloppe">
    <table class="tableau">
        <thead>
            <tr>
                <th>Employe <span class="mg">/ Mpiasa</span></th>
                <th>Poste <span class="mg">/ Asa</span></th>
                <?php if ($peutVoirCout): ?><th>Taux/jour</th><?php endif; ?>
                <th>Presence <span class="mg">/ Fanatrehana</span></th>
                <th>Lot <span class="mg">/ Ampahany</span></th>
                <?php if ($peutVoirCout): ?><th>Cout <span class="mg">/ Vidiny</span></th><?php endif; ?>
            </tr>
        </thead>
        <tbody id="corps-pointage">
            <tr><td class="vide" colspan="<?= 4 + (int) $peutVoirCout ?>">Chargement&hellip;</td></tr>
        </tbody>
    </table>
</div>

<div class="actions-form" style="margin-top:16px">
    <?php if ($peutModifier): ?>
    <button class="bouton bouton-primaire" id="btn-enregistrer">Enregistrer la feuille <span class="mg">&middot; Tehirizo</span></button>
    <?php else: ?>
    <p class="sous-titre">Consultation seule : la saisie et la modification sont réservées au chef de chantier et au directeur.</p>
    <?php endif; ?>
    <span id="message-pointage" class="sous-titre"></span>
</div>
<?php
$contenu = ob_get_clean();

View::rendre('layouts.base', [
    'titre'       => $titre,
    'contenu'     => $contenu,
    'scripts'     => ['js/auth.js', 'js/format.js', 'js/pointage.js'],
    'config_json' => ['id' => $id, 'peutModifier' => $peutModifier, 'peutVoirCout' => $peutVoirCout],
]);
