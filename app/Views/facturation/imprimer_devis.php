<?php

use App\Core\View;

ob_start();
?>
<div class="actions-form zone-non-imprimable" style="margin-bottom:16px">
    <button class="bouton bouton-primaire" onclick="window.print()">Imprimer / PDF</button>
    <a class="bouton bouton-secondaire" id="lien-retour" href="#">Retour</a>
</div>

<div id="devis-impression" class="feuille-impression">Chargement&hellip;</div>
<?php
$contenu = ob_get_clean();
View::rendre('layouts.base', [
    'titre'       => $titre,
    'contenu'     => $contenu,
    'bare'        => true,
    'scripts'     => ['js/auth.js', 'js/format.js', 'js/devis-print.js'],
    'config_json' => ['id' => $id],
]);
