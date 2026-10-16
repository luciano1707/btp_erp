<?php

use App\Core\View;

$contenu = '<section class="hero"><h1>401</h1><p class="sous-titre">Votre session a expire ou vous devez vous connecter.</p>'
    . '<p><a class="lien" href="' . e(url('/connexion')) . '">Se connecter</a></p></section>';

View::rendre('layouts.base', ['titre' => 'Authentification requise', 'contenu' => $contenu, 'bare' => true]);
