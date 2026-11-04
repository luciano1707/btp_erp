<?php
/**
 * @var string $titre
 */
use App\Core\View;

ob_start();
?>
<div class="barre-actions">
    <button class="btn" type="button" id="btn-tout-lire">Tout marquer comme lu</button>
</div>
<div class="carte">
    <div class="entete-carte">
        <h2>Notifications</h2>
        <div class="filtres">
            <label class="champ-inline">
                <input type="checkbox" id="filtre-non-lues">
                <span>Non lues uniquement</span>
            </label>
        </div>
    </div>
    <div id="liste-notifications" class="notif-liste">Chargement…</div>
</div>
<?php
$contenu = ob_get_clean();

View::rendre('layouts.base', [
    'titre'   => $titre,
    'contenu' => $contenu,
    'scripts' => ['js/auth.js', 'js/format.js', 'js/notifications.js'],
]);
