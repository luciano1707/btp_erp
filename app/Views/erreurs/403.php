<?php

use App\Core\View;

$contenu = '<section class="hero"><h1>403</h1><p class="sous-titre">Vous n\'avez pas les droits necessaires pour acceder a cette page.</p>'
    . '<p><a class="lien" href="' . e(url('/tableau-de-bord')) . '">Retour au tableau de bord</a></p></section>';

View::rendre('layouts.base', ['titre' => 'Acces refuse', 'contenu' => $contenu, 'bare' => true]);
