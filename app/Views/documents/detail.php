<?php
/** @var string $titre */
/** @var int|string|null $id */
use App\Core\View;
ob_start();
?>
<div class="page-header"><h1><?= htmlspecialchars($titre ?? 'Détail document') ?></h1></div>
<p>Identifiant : <?= htmlspecialchars($id ?? '') ?></p>
<?php
$contenu = ob_get_clean();
View::rendre('layouts.base', ['titre' => $titre ?? 'Détail document', 'contenu' => $contenu, 'scripts' => ['js/auth.js']]);
