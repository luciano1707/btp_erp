<?php
/**
 * @var string $titre
 * @var int|string|null $id
 * @var bool $peutRepondre
 */
use App\Core\View;

ob_start();
?>
<div class="barre-actions">
    <a class="btn" href="<?= e(url('/rfi')) ?>">Retour à la liste</a>
</div>
<div class="carte">
    <div class="entete-carte">
        <h2>Détail de la RFI</h2>
        <div class="actions-groupe" id="actions-rfi" data-peut-repondre="<?= !empty($peutRepondre) ? '1' : '0' ?>"></div>
    </div>
    <div id="rfi-detail">Chargement…</div>
    <div id="bloc-reponse" hidden style="margin-top:16px">
        <label class="champ">
            <span>Réponse</span>
            <textarea id="reponse-rfi" rows="5"></textarea>
        </label>
        <div class="actions-form">
            <button class="btn btn-primaire" type="button" id="btn-repondre-rfi">Envoyer la réponse</button>
        </div>
    </div>
</div>
<?php
$contenu = ob_get_clean();

View::rendre('layouts.base', [
    'titre'   => $titre,
    'contenu' => $contenu,
    'scripts' => ['js/auth.js', 'js/format.js', 'js/rfi.js'],
]);
