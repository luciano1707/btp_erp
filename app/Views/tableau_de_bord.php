<?php
/**
 * Tableau de bord (coquille protegee cote client).
 * @var string $titre
 */

use App\Core\View;

ob_start();
?>
<div class="tdb-hero">
    <div>
        <h2 id="tdb-greeting">Bonjour</h2>
        <p class="sous-titre" id="tdb-date">Voici l'activit&eacute; de votre entreprise.</p>
    </div>
</div>

<div id="banniere-mdp" class="banniere-avertissement" hidden>
    &#9888; Vous utilisez encore un mot de passe provisoire. Pensez &agrave; le changer.
</div>

<section class="grille-kpi" id="grille-kpi">
    <div class="kpi">
        <div class="kpi-tete"><span class="kpi-libelle">Chantiers actifs</span>
            <span class="kpi-icone"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 21h18"/><path d="M6 21V7l7-4 7 4v14"/></svg></span></div>
        <div class="kpi-valeur" id="kpi-chantiers">&mdash;</div>
        <div class="kpi-note" id="kpi-chantiers-note">&nbsp;</div>
    </div>
    <div class="kpi" data-financial hidden>
        <div class="kpi-tete"><span class="kpi-libelle">CA facture</span>
            <span class="kpi-icone"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 3v18h18"/><path d="M7 14l3-3 3 2 4-5"/></svg></span></div>
        <div class="kpi-valeur" id="kpi-ca">&mdash;</div>
        <div class="kpi-note">cumul des factures emises</div>
    </div>
    <div class="kpi" data-financial hidden>
        <div class="kpi-tete"><span class="kpi-libelle">CA encaisse</span>
            <span class="kpi-icone vert"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6L9 17l-5-5"/></svg></span></div>
        <div class="kpi-valeur" id="kpi-encaisse">&mdash;</div>
        <div class="kpi-note" id="kpi-encaisse-note">&nbsp;</div>
    </div>
    <div class="kpi" data-financial hidden>
        <div class="kpi-tete"><span class="kpi-libelle">Marge brute</span>
            <span class="kpi-icone ambre"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M19 5L5 19"/><circle cx="6.5" cy="6.5" r="2.5"/><circle cx="17.5" cy="17.5" r="2.5"/></svg></span></div>
        <div class="kpi-valeur" id="kpi-marge">&mdash;</div>
        <div class="kpi-note" id="kpi-marge-note">&nbsp;</div>
    </div>
</section>

<div class="grille-tdb">
    <article class="carte" data-financial hidden>
        <div class="entete-graphique">
            <div><h2>Facture vs encaisse</h2><p class="sous-titre">6 derniers mois &middot; en Ariary</p></div>
            <div class="legende">
                <span class="pastille pastille-bleu"></span> Facture
                <span class="pastille pastille-vert"></span> Encaisse
            </div>
        </div>
        <div id="graphique-mensuel"><p class="chargement">Chargement&hellip;</p></div>
    </article>
    <article class="carte" data-financial hidden>
        <h2>CA facture par chantier</h2>
        <p class="sous-titre" style="margin-bottom:8px">R&eacute;partition du chiffre d'affaires.</p>
        <div id="donut-ca"><p class="chargement">Chargement&hellip;</p></div>
    </article>
</div>

<div class="grille-tdb">
    <article class="carte">
        <h2>Avancement des chantiers</h2>
        <p class="sous-titre" style="margin-bottom:14px">Avancement physique moyen, pondere par le budget des lots.</p>
        <div id="planning-chantiers"><p class="chargement">Chargement&hellip;</p></div>
    </article>
    <article class="carte">
        <h2>Alertes</h2>
        <div class="liste-alertes" id="liste-alertes"><p class="chargement">Chargement&hellip;</p></div>
    </article>
</div>

<section class="grille-kpi">
    <div class="kpi" data-financial hidden>
        <div class="kpi-tete"><span class="kpi-libelle">Reste a encaisser</span>
            <span class="kpi-icone rouge"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 1v22M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg></span></div>
        <div class="kpi-valeur" id="kpi-reste">&mdash;</div>
        <div class="kpi-note">factures emises non soldees</div>
    </div>
    <div class="kpi" data-financial hidden>
        <div class="kpi-tete"><span class="kpi-libelle">Cout total engage</span>
            <span class="kpi-icone"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="16" rx="2"/><path d="M3 10h18"/></svg></span></div>
        <div class="kpi-valeur" id="kpi-cout">&mdash;</div>
        <div class="kpi-note">main d'&oelig;uvre + materiaux</div>
    </div>
    <div class="kpi" data-financial hidden>
        <div class="kpi-tete"><span class="kpi-libelle">Factures impayees</span>
            <span class="kpi-icone ambre"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M14 3H7a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V8z"/><path d="M14 3v5h5"/></svg></span></div>
        <div class="kpi-valeur" id="kpi-impayees">&mdash;</div>
        <div class="kpi-note">a relancer</div>
    </div>
    <div class="kpi">
        <div class="kpi-tete"><span class="kpi-libelle">Alertes stock</span>
            <span class="kpi-icone rouge"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M10.3 3.9L1.8 18a2 2 0 0 0 1.7 3h17a2 2 0 0 0 1.7-3L13.7 3.9a2 2 0 0 0-3.4 0z"/><path d="M12 9v4M12 17h0"/></svg></span></div>
        <div class="kpi-valeur" id="kpi-stock">&mdash;</div>
        <div class="kpi-note">materiaux sous le seuil</div>
    </div>
</section>
<?php
$contenu = ob_get_clean();

View::rendre('layouts.base', [
    'titre'   => $titre,
    'contenu' => $contenu,
    'scripts' => ['js/auth.js', 'js/format.js', 'js/charts.js', 'js/dashboard.js'],
]);
