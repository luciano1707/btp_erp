<?php
/**
 * Page de connexion (Phase 1).
 * Direction artistique : « chantier numerique en profondeur ».
 * @var string $titre
 */

use App\Core\View;

ob_start();
?>
<?php
$nomApp = \App\Core\Env::get('APP_NAME', 'Digital Chantier');
$sigle  = \App\Core\Env::get('BRAND_SIGLE', 'DC');
?>
<div class="ecran-connexion" id="ecran-connexion">
    <aside class="panneau-marque">
        <div class="pm-fond" aria-hidden="true"></div>
        <div class="pm-grille" aria-hidden="true"></div>
        <div class="pm-halo pm-halo-1" aria-hidden="true"></div>
        <div class="pm-halo pm-halo-2" aria-hidden="true"></div>

        <!-- Scene 3D decorative (chantier, finance, ressources) -->
        <div class="scene3d" id="scene3d" aria-hidden="true">
            <div class="s3d-cubes">
                <div class="cube cube-1"><i></i><i></i><i></i><i></i><i></i><i></i></div>
                <div class="cube cube-2"><i></i><i></i><i></i><i></i><i></i><i></i></div>
                <div class="cube cube-3"><i></i><i></i><i></i><i></i><i></i><i></i></div>
                <div class="cube cube-4"><i></i><i></i><i></i><i></i><i></i><i></i></div>
            </div>

            <div class="s3d-pilier" aria-hidden="true"><i></i><i></i><i></i></div>
        </div>

        <div class="pm-haut">
            <span class="logo-auth" aria-hidden="true"><?= e($sigle) ?></span>
            <span class="nom-auth-clair"><?= e($nomApp) ?></span>
        </div>
        <div class="pm-centre">
            <h1>Pilotez vos chantiers,<br>en toute transparence.</h1>
            <p>La solution de gestion complete pour les entreprises de b&acirc;timent et travaux publics &agrave; Madagascar.</p>
            <ul class="pm-atouts">
                <li><span class="pm-check" aria-hidden="true">&#10003;</span> Suivi financier &amp; tr&eacute;sorerie en temps r&eacute;el</li>
                <li><span class="pm-check" aria-hidden="true">&#10003;</span> Pointage terrain &amp; co&ucirc;t de main d'&oelig;uvre</li>
                <li><span class="pm-check" aria-hidden="true">&#10003;</span> Devis, factures &amp; relances automatis&eacute;es</li>
                <li><span class="pm-check" aria-hidden="true">&#10003;</span> Tra&ccedil;abilit&eacute; de chaque Ariary d&eacute;pens&eacute;</li>
            </ul>
        </div>
        <div class="pm-bas">Mahajanga, Madagascar &middot; Usage interne</div>
    </aside>

    <main class="panneau-form">
        <div class="carte-auth">
            <div class="marque-auth mobile-only">
                <span class="logo-auth"><?= e($sigle) ?></span>
                <span class="nom-auth"><?= e($nomApp) ?></span>
            </div>
            <h1 class="titre-auth">Bienvenue</h1>
            <p class="sous-titre">Connectez-vous &agrave; votre espace de gestion.</p>

            <form id="form-connexion" class="formulaire" autocomplete="on" novalidate>
                <div class="champ">
                    <label for="email">Adresse e-mail</label>
                    <input type="email" id="email" name="email" required autofocus placeholder="vous@entreprise.mg">
                </div>
                <div class="champ">
                    <label for="mot_de_passe">Mot de passe</label>
                    <input type="password" id="mot_de_passe" name="mot_de_passe" required placeholder="&bull;&bull;&bull;&bull;&bull;&bull;&bull;&bull;">
                </div>
                <p class="connexion-aide"><a class="lien" href="<?= e(url('/mot-de-passe-oublie')) ?>">Mot de passe oublie ?</a></p>
                <div id="message-erreur" class="message-erreur" role="alert" hidden></div>
                <button type="submit" id="btn-connexion" class="bouton bouton-primaire bouton-bloc">
                    <span class="btn-icone" id="btn-icone" aria-hidden="true">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 5v14M19 12l-7-7-7 7"/></svg>
                    </span>
                    <span id="btn-texte">Se connecter</span>
                    <span class="btn-spinner" id="btn-spinner" aria-hidden="true"></span>
                </button>
            </form>
        </div>
    </main>
</div>

<!-- Transition "vivante" : connection reussie -> tableau de bord
     Voile plein ecran anime (cube 3D + barre de progression chantier). -->
<div id="transition-chantier" class="transition-chantier" role="status" aria-live="polite" hidden>
    <div class="tc-fond" aria-hidden="true"></div>
    <div class="tc-grille" aria-hidden="true"></div>
    <div class="tc-halo tc-halo-1" aria-hidden="true"></div>
    <div class="tc-contenu">
        <div class="tc-cubes" aria-hidden="true">
            <div class="cube tc-cube tc-cube-1"><i></i><i></i><i></i><i></i><i></i><i></i></div>
            <div class="cube tc-cube tc-cube-2"><i></i><i></i><i></i><i></i><i></i><i></i></div>
            <div class="cube tc-cube tc-cube-3"><i></i><i></i><i></i><i></i><i></i><i></i></div>
        </div>
        <h2 class="tc-titre">Pr&eacute;paration du chantier&hellip;</h2>
        <div class="tc-jauge" role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-valuenow="0" id="tc-jauge">
            <span class="tc-jauge-rempl" id="tc-jauge-rempl"></span>
        </div>
        <p class="tc-texte" id="tc-texte">Inventaire des mat&eacute;riaux&hellip;</p>
    </div>
</div>
    </main>

    <!-- Transition version : voile chantier 3D (cube + progression) -->
    <div id="transition-chantier" class="transition-chantier" role="status" aria-live="polite" hidden>
        <div class="tc-grille" aria-hidden="true"></div>
        <div class="tc-cube" aria-hidden="true"><i></i><i></i><i></i><i></i><i></i><i></i></div>
        <div id="tc-jauge" class="tc-jauge" role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-valuenow="0">
            <span class="tc-jauge-rempl" id="tc-jauge-rempl"></span>
        </div>
        <p class="tc-texte" id="tc-texte">Inventaire des mat&eacute;riaux&hellip;</p>
    </div>
</div>
<?php
$contenu = ob_get_clean();

View::rendre('layouts.base', [
    'titre'   => $titre,
    'contenu' => $contenu,
    'bare'    => true,
    'scripts' => ['js/auth.js', 'js/connexion.js'],
]);