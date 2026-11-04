<?php
/** @var string $titre */
use App\Core\View;
ob_start();
?>
<div class="page-header"><h1><?= htmlspecialchars($titre ?? 'Documents') ?></h1></div>
<p>Module Documents (en cours de développement).</p>
<?php
$contenu = ob_get_clean();
View::rendre('layouts.base', ['titre' => $titre ?? 'Documents', 'contenu' => $contenu, 'scripts' => ['js/auth.js']]);
