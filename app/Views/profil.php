<?php

use App\Core\View;

ob_start();
?>
<section class="entete-liste">
    <div>
        <h1>Mon profil</h1>
        <p class="sous-titre description-liste">Gerez vos informations personnelles et votre securite de connexion.</p>
    </div>
</section>

<div class="grille-parametres">
    <article class="carte">
        <h2>Informations personnelles</h2>
        <form id="form-profil" class="formulaire">
            <div class="champ"><label for="profil_nom">Nom</label><input type="text" id="profil_nom" required></div>
            <div class="champ"><label for="profil_prenom">Prenom</label><input type="text" id="profil_prenom" required></div>
            <div class="champ"><label for="profil_email">E-mail</label><input type="email" id="profil_email" required></div>
            <div class="champ"><label for="profil_telephone">Telephone</label><input type="tel" id="profil_telephone"></div>
            <div class="champ"><label>Role</label><input type="text" id="profil_role" readonly></div>
            <div id="message-profil" class="message-erreur" hidden></div>
            <div class="actions-form"><button type="submit" class="bouton bouton-primaire" id="btn-profil">Enregistrer</button><span class="sous-titre" id="statut-profil"></span></div>
        </form>
    </article>

    <article class="carte">
        <h2>Mot de passe</h2>
        <p class="sous-titre">Changez votre mot de passe sans modifier votre role ni vos permissions.</p>
        <form id="form-mot-de-passe" class="formulaire">
            <div class="champ"><label for="mot_de_passe_actuel">Mot de passe actuel</label><input type="password" id="mot_de_passe_actuel" autocomplete="current-password" required></div>
            <div class="champ"><label for="nouveau_mot_de_passe">Nouveau mot de passe</label><input type="password" id="nouveau_mot_de_passe" minlength="8" autocomplete="new-password" required></div>
            <div class="champ"><label for="confirmation_mot_de_passe">Confirmation</label><input type="password" id="confirmation_mot_de_passe" minlength="8" autocomplete="new-password" required></div>
            <div id="message-mot-de-passe" class="message-erreur" hidden></div>
            <div class="actions-form"><button type="submit" class="bouton bouton-primaire" id="btn-mot-de-passe">Modifier le mot de passe</button></div>
        </form>
    </article>
</div>
<?php
$contenu = ob_get_clean();
View::rendre('layouts.base', [
    'titre' => $titre,
    'contenu' => $contenu,
    'scripts' => ['js/auth.js', 'js/profil.js'],
]);
