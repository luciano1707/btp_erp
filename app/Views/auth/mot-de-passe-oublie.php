<?php

use App\Core\View;

$nomApp = \App\Core\Env::get('APP_NAME', 'Digital Chantier');
$sigle = \App\Core\Env::get('BRAND_SIGLE', 'DC');

ob_start();
?>
<div class="ecran-connexion" id="ecran-oubli">
    <div class="oubli-scene" aria-hidden="true">
        <div class="oubli-grille"></div>
        <div class="oubli-orbite oubli-orbite-1"></div>
        <div class="oubli-orbite oubli-orbite-2"></div>
        <div class="oubli-cube">
            <i></i><i></i><i></i><i></i><i></i><i></i>
        </div>
        <div class="oubli-cube oubli-cube-petit">
            <i></i><i></i><i></i><i></i><i></i><i></i>
        </div>
    </div>
    <main class="panneau-form panneau-form-seul">
        <div class="carte-auth carte-oubli">
            <div class="marque-auth">
                <span class="logo-auth" aria-hidden="true"><?= e($sigle) ?></span>
                <span class="nom-auth"><?= e($nomApp) ?></span>
            </div>
            <div class="oubli-entete">
                <span class="oubli-icone" aria-hidden="true">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="4" y="10" width="16" height="11" rx="2"/><path d="M8 10V7a4 4 0 1 1 8 0v3M12 14v3"/></svg>
                </span>
                <span class="oubli-etiquette">R&eacute;cup&eacute;ration du compte</span>
            </div>
            <h1 class="titre-auth">Mot de passe oubli&eacute; ?</h1>
            <p class="sous-titre">Recevez un code de v&eacute;rification par e-mail pour choisir un nouveau mot de passe.</p>

            <form id="form-demande-otp" class="formulaire">
                <div class="champ">
                    <label for="otp-email">Adresse e-mail</label>
                    <input type="email" id="otp-email" name="email" autocomplete="email" required placeholder="vous@entreprise.mg">
                </div>
                <div id="message-otp" class="message-erreur" role="status" aria-live="polite" hidden></div>
                <button type="submit" id="btn-demande-otp" class="bouton bouton-primaire bouton-bloc">
                    <span>Envoyer le code</span>
                    <svg aria-hidden="true" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M22 2 11 13"/><path d="m22 2-7 20-4-9-9-4 20-7Z"/></svg>
                </button>
            </form>

            <form id="form-reinitialisation" class="formulaire" hidden>
                <div class="champ">
                    <label for="otp-code">Code reçu par e-mail</label>
                    <input type="text" id="otp-code" name="code" inputmode="numeric" pattern="[0-9]{6}" maxlength="6" autocomplete="one-time-code" required placeholder="000000">
                </div>
                <div class="champ">
                    <label for="otp-nouveau">Nouveau mot de passe</label>
                    <input type="password" id="otp-nouveau" name="nouveau_mot_de_passe" minlength="8" autocomplete="new-password" required placeholder="8 caractères minimum">
                </div>
                <div class="champ">
                    <label for="otp-confirmation">Confirmation</label>
                    <input type="password" id="otp-confirmation" name="nouveau_mot_de_passe_confirmation" minlength="8" autocomplete="new-password" required placeholder="Saisissez-le à nouveau">
                </div>
                <div id="message-reinitialisation" class="message-erreur" role="status" aria-live="polite" hidden></div>
                <button type="submit" id="btn-reinitialisation" class="bouton bouton-primaire bouton-bloc">
                    <span>Réinitialiser le mot de passe</span>
                    <svg aria-hidden="true" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14M13 6l6 6-6 6"/></svg>
                </button>
            </form>

            <p class="connexion-aide"><a class="lien" href="<?= e(url('/connexion')) ?>"><span aria-hidden="true">&larr;</span> Retour à la connexion</a></p>
        </div>
    </main>
</div>
<?php
$contenu = ob_get_clean();
View::rendre('layouts.base', [
    'titre' => $titre,
    'contenu' => $contenu,
    'bare' => true,
    'scripts' => ['js/auth.js', 'js/mot-de-passe-oublie.js'],
]);
