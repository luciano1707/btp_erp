<?php
/**
 * Contenu de la page d'accueil (Phase 0).
 * @var string $application
 */
?>
<section class="hero">
    <h1>Bienvenue sur <?= e($application) ?></h1>
    <p class="sous-titre">
        ERP de gestion de chantiers &mdash; b&acirc;timent &amp; travaux publics.
        Tra&ccedil;abilit&eacute; totale : chaque action, chaque Ariary, chaque heure.
    </p>
</section>

<section class="cartes">
    <article class="carte">
        <h2>&Eacute;tat du socle</h2>
        <ul class="liste-etat">
            <li>Architecture MVC maison <span class="ok">&#10003;</span></li>
            <li>Routeur web + API <span class="ok">&#10003;</span></li>
            <li>Authentification JWT (moteur pr&ecirc;t) <span class="ok">&#10003;</span></li>
            <li>Journal d'audit <span class="ok">&#10003;</span></li>
        </ul>
    </article>

    <article class="carte">
        <h2>Test de l'API</h2>
        <p>Appel en direct de <code>GET /api/v1/health</code> :</p>
        <div id="etat-api" class="etat-api" data-endpoint="api/v1/health">
            <span class="chargement">Interrogation de l'API&hellip;</span>
        </div>
    </article>

    <article class="carte">
        <h2>Format Ariary</h2>
        <p>Exemple d'affichage mon&eacute;taire :</p>
        <p class="montant"><?= e(ariary(1234567)) ?></p>
    </article>
</section>
