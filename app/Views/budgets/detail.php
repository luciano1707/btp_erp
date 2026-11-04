<?php
/**
 * @var string $titre
 * @var int|string|null $id
 * @var bool $peutModifier
 */
use App\Core\View;

ob_start();
?>
<div class="barre-actions">
    <a class="btn" href="<?= e(url('/budgets')) ?>">Retour à la liste</a>
    <?php if (!empty($peutModifier)): ?><a class="btn btn-primaire" href="<?= e(url('/budgets/' . $id . '/modifier')) ?>">Modifier</a><?php endif; ?>
</div>

<!-- KPI du budget -->
<div class="cartes" id="kpi-budget-detail" style="margin-bottom: 24px;">
    <article class="carte">
        <h3>Prévisionnel</h3>
        <p class="kpi-valeur" id="kpi-prevu">0 Ar</p>
    </article>
    <article class="carte">
        <h3>Engagé</h3>
        <p class="kpi-valeur" id="kpi-engage">0 Ar</p>
    </article>
    <article class="carte">
        <h3>Réel</h3>
        <p class="kpi-valeur" id="kpi-reel">0 Ar</p>
    </article>
    <article class="carte">
        <h3>Restant</h3>
        <p class="kpi-valeur" id="kpi-restant">0 Ar</p>
    </article>
</div>

<div class="carte">
    <div class="entete-carte">
        <h2>Détail du budget</h2>
        <div class="actions-groupe" id="actions-budget" data-peut-modifier="<?= !empty($peutModifier) ? '1' : '0' ?>"></div>
    </div>
    
    <!-- Onglets -->
    <div class="onglets">
        <button class="onglet actif" data-onglet="general">Général</button>
        <button class="onglet" data-onglet="lignes">Lignes budgétaires</button>
        <button class="onglet" data-onglet="depenses">Dépenses</button>
        <button class="onglet" data-onglet="devis">Devis rattachés</button>
    </div>
    
    <div id="budget-detail">
        <!-- Contenu chargé par JS -->
    </div>
</div>
<?php
$contenu = ob_get_clean();

View::rendre('layouts.base', [
    'titre'   => $titre,
    'contenu' => $contenu,
    'scripts' => ['js/auth.js', 'js/format.js', 'js/budgets.js'],
    'config_json' => [
        'id' => $id,
        'peutModifier' => !empty($peutModifier),
    ],
]);
