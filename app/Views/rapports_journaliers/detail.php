<?php
/**
 * @var string $titre
 * @var int|string|null $id
 * @var bool $peutModifier
 */
use App\Core\View;

ob_start();
?>
<div class="barre-actions">
    <a class="btn" href="<?= e(url('/rapports-journaliers')) ?>">Retour à la liste</a>
    <?php if (!empty($peutModifier)): ?><a class="btn btn-primaire" href="<?= e(url('/rapports-journaliers/' . $id . '/modifier')) ?>">Modifier</a><?php endif; ?>
</div>
<div class="carte">
    <div class="entete-carte">
        <h2>Détail rapport journalier</h2>
    </div>
    <div id="rapport-detail">Chargement...</div>
</div>
<?php
$contenu = ob_get_clean();

View::rendre('layouts.base', [
    'titre'   => $titre,
    'contenu' => $contenu,
    'scripts' => ['js/auth.js', 'js/format.js', 'js/rapports-journaliers-detail.js'],
]);
