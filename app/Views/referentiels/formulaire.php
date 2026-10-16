<?php
/**
 * Formulaire de creation / edition d'un referentiel.
 * Les champs sont generes depuis le registre de configuration.
 * @var string $titre
 * @var string $entite
 * @var array<string,mixed> $config
 * @var int|null $id
 */

use App\Core\View;

ob_start();
?>
<section class="entete-liste">
    <h1><?= e(ucfirst($titre)) ?></h1>
</section>

<form id="form-ressource" class="formulaire formulaire-large carte">
    <?php foreach ($config['champs'] as $champ): ?>
        <?php
        $nom    = $champ['champ'];
        $type   = $champ['type'] ?? 'text';
        $requis = !empty($champ['requis']);
        ?>
        <div class="champ <?= $type === 'checkbox' ? 'champ-checkbox' : '' ?>">
            <?php if ($type === 'checkbox'): ?>
                <label>
                    <input type="checkbox" id="<?= e($nom) ?>" name="<?= e($nom) ?>" <?= !empty($champ['defaut']) ? 'checked' : '' ?>>
                    <?= e($champ['libelle']) ?>
                </label>

            <?php elseif ($type === 'select'): ?>
                <label for="<?= e($nom) ?>"><?= e($champ['libelle']) ?><?= $requis ? ' *' : '' ?></label>
                <select id="<?= e($nom) ?>" name="<?= e($nom) ?>" <?= $requis ? 'required' : '' ?>>
                    <?php foreach ($champ['options'] as $valeur => $libelle): ?>
                        <option value="<?= e((string) $valeur) ?>"><?= e($libelle) ?></option>
                    <?php endforeach; ?>
                </select>

            <?php elseif ($type === 'textarea'): ?>
                <label for="<?= e($nom) ?>"><?= e($champ['libelle']) ?><?= $requis ? ' *' : '' ?></label>
                <textarea id="<?= e($nom) ?>" name="<?= e($nom) ?>" rows="2" <?= $requis ? 'required' : '' ?>></textarea>

            <?php else: ?>
                <label for="<?= e($nom) ?>"><?= e($champ['libelle']) ?><?= $requis ? ' *' : '' ?></label>
                <input type="<?= e($type) ?>" id="<?= e($nom) ?>" name="<?= e($nom) ?>"
                       <?= $type === 'number' ? 'inputmode="numeric" min="0"' : '' ?> <?= $requis ? 'required' : '' ?>>
            <?php endif; ?>
        </div>
    <?php endforeach; ?>

    <div id="message-erreur" class="message-erreur" hidden></div>

    <div class="actions-form">
        <button type="submit" id="btn-enregistrer" class="bouton bouton-primaire">Enregistrer</button>
        <a class="bouton bouton-secondaire" href="<?= e(url('/referentiels/' . $entite)) ?>">Annuler</a>
    </div>
</form>
<?php
$contenu = ob_get_clean();

$configJs = [
    'entite'   => $entite,
    'endpoint' => $config['endpoint'],
    'id'       => $id,
    'champs'   => array_map(static fn ($c) => ['champ' => $c['champ'], 'type' => $c['type'] ?? 'text'], $config['champs']),
];

View::rendre('layouts.base', [
    'titre'       => $titre,
    'contenu'     => $contenu,
    'scripts'     => ['js/auth.js', 'js/ressource-form.js'],
    'config_json' => $configJs,
]);
