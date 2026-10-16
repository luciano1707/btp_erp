<?php

use App\Core\View;

$contenu = '<section class="hero"><h1>404</h1><p class="sous-titre">La page demand&eacute;e est introuvable.</p>'
    . '<p><a class="lien" href="' . e(url('/')) . '">Retour &agrave; l\'accueil</a></p></section>';

View::rendre('layouts.base', ['titre' => 'Page introuvable', 'contenu' => $contenu, 'bare' => true]);
