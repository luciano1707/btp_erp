<?php

use App\Core\View;

ob_start();
?>
<section class="entete-liste">
    <div><h1>Parametres de l'entreprise</h1><p class="sous-titre">Ces informations et votre logo apparaissent sur les devis, factures et re&ccedil;us.</p></div>
</section>

<div class="grille-parametres">
    <article class="carte">
        <h2>Logo de l'entreprise</h2>
        <div class="zone-logo">
            <div class="apercu-logo" id="apercu-logo"><span class="apercu-vide">Aucun logo</span></div>
            <div class="actions-logo">
                <input type="file" id="fichier-logo" accept="image/png,image/jpeg,image/webp" hidden>
                <button type="button" class="bouton bouton-secondaire" id="btn-choisir">Choisir un fichier&hellip;</button>
                <button type="button" class="bouton bouton-primaire" id="btn-envoyer-logo" disabled>T&eacute;l&eacute;verser</button>
                <p class="sous-titre" id="nom-fichier">PNG, JPG ou WEBP &middot; 2 Mo max.</p>
                <p class="message-erreur" id="erreur-logo" hidden></p>
            </div>
        </div>
    </article>

    <article class="carte">
        <h2>Coordonn&eacute;es</h2>
        <form id="form-parametres" class="formulaire">
            <div class="champ"><label for="entreprise_nom">Nom / Raison sociale</label><input type="text" id="entreprise_nom"></div>
            <div class="champ"><label for="entreprise_adresse">Adresse</label><textarea id="entreprise_adresse" rows="2"></textarea></div>
            <div class="grille-2">
                <div class="champ"><label for="entreprise_telephone">T&eacute;l&eacute;phone</label><input type="text" id="entreprise_telephone"></div>
                <div class="champ"><label for="entreprise_email">E-mail</label><input type="email" id="entreprise_email"></div>
            </div>
            <div class="grille-2">
                <div class="champ"><label for="entreprise_nif">NIF</label><input type="text" id="entreprise_nif"></div>
                <div class="champ"><label for="entreprise_stat">STAT</label><input type="text" id="entreprise_stat"></div>
            </div>
            <div id="message-parametres" class="message-erreur" hidden></div>
            <div class="actions-form">
                <button type="submit" id="btn-enregistrer" class="bouton bouton-primaire">Enregistrer</button>
                <span class="sous-titre" id="statut-enregistre"></span>
            </div>
        </form>
    </article>

    <article class="carte">
        <h2>S&eacute;curit&eacute; du compte</h2>
        <p class="sous-titre">Modifiez votre mot de passe de connexion.</p>
        <form id="form-mot-de-passe" class="formulaire">
            <div class="champ">
                <label for="mot_de_passe_actuel">Mot de passe actuel</label>
                <input type="password" id="mot_de_passe_actuel" autocomplete="current-password" required>
            </div>
            <div class="grille-2">
                <div class="champ">
                    <label for="nouveau_mot_de_passe">Nouveau mot de passe</label>
                    <input type="password" id="nouveau_mot_de_passe" autocomplete="new-password" minlength="8" required>
                </div>
                <div class="champ">
                    <label for="confirmation_mot_de_passe">Confirmer le nouveau mot de passe</label>
                    <input type="password" id="confirmation_mot_de_passe" autocomplete="new-password" minlength="8" required>
                </div>
            </div>
            <div id="message-mot-de-passe" class="message-erreur" hidden></div>
            <div class="actions-form">
                <button type="submit" id="btn-mot-de-passe" class="bouton bouton-primaire">Modifier le mot de passe</button>
                <span class="sous-titre" id="statut-mot-de-passe"></span>
            </div>
        </form>
    </article>
</div>
<?php
$contenu = ob_get_clean();
View::rendre('layouts.base', [
    'titre'   => $titre,
    'contenu' => $contenu,
    'scripts' => ['js/auth.js', 'js/format.js', 'js/parametres.js'],
]);
