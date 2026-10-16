<?php
/**
 * Vue d'accueil (Phase 0). Verifie l'API via fetch et affiche l'etat du socle.
 * @var string $titre
 * @var string $application
 */

use App\Core\View;

$contenu = View::capturer('partials.accueil_contenu', ['application' => $application]);
View::rendre('layouts.base', ['titre' => $titre, 'contenu' => $contenu, 'bare' => true, 'scripts' => ['js/app.js']]);
