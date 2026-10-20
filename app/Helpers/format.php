<?php

/**
 * Fonctions d'aide globales (formatage).
 * Chargees explicitement au demarrage (les fonctions ne passent pas par l'autoloader).
 */

if (!function_exists('ariary')) {
    /**
     * Formate un montant en Ariary : "1 234 567 Ar" (separateur d'espace, sans centimes).
     */
    function ariary(int|float|string $montant): string
    {
        return number_format((float) $montant, 0, ',', ' ') . ' Ar';
    }
}

if (!function_exists('e')) {
    /**
     * Echappe une chaine pour affichage HTML sur (protection XSS dans les vues).
     */
    function e(?string $valeur): string
    {
        return htmlspecialchars((string) $valeur, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
    }
}

if (!function_exists('base_url')) {
    /**
     * URL de base de l'application (sans slash final), issue de APP_URL.
     */
    function base_url(): string
    {
        if (\App\Core\Env::get('APP_DESKTOP', false) === true) {
            return '';
        }

        return rtrim((string) \App\Core\Env::get('APP_URL', ''), '/');
    }
}

if (!function_exists('asset')) {
    /**
     * URL absolue vers un fichier statique du dossier assets/, avec cache-busting.
     * On ajoute ?v=<date de modification> : quand le fichier change, l'URL change,
     * ce qui force le navigateur a recharger la nouvelle version (fini le cache perime).
     * Ex: asset('css/app.css') => http://localhost/BTP_ERP/assets/css/app.css?v=1720440000
     */
    function asset(string $chemin): string
    {
        $chemin = ltrim($chemin, '/');
        $version = '';
        $fichier = dirname(__DIR__, 2) . '/assets/' . $chemin;
        if (is_file($fichier)) {
            $version = '?v=' . filemtime($fichier);
        }
        return base_url() . '/assets/' . $chemin . $version;
    }
}

if (!function_exists('url')) {
    /**
     * URL absolue vers une route de l'application.
     * Ex: url('/connexion') => http://localhost/BTP_ERP/connexion
     */
    function url(string $chemin = ''): string
    {
        return base_url() . '/' . ltrim($chemin, '/');
    }
}

if (!function_exists('teinte')) {
    /**
     * Ajuste la luminosite d'une couleur hexadecimale.
     * $facteur negatif = plus sombre ; positif = plus clair (vers le blanc). Plage utile : -1 a 1.
     */
    function teinte(string $hex, float $facteur): string
    {
        $hex = ltrim($hex, '#');
        if (strlen($hex) === 3) {
            $hex = $hex[0] . $hex[0] . $hex[1] . $hex[1] . $hex[2] . $hex[2];
        }
        if (strlen($hex) !== 6) {
            return '#' . $hex;
        }
        $r = hexdec(substr($hex, 0, 2));
        $g = hexdec(substr($hex, 2, 2));
        $b = hexdec(substr($hex, 4, 2));

        if ($facteur < 0) {
            $f = 1 + $facteur;
            $r *= $f; $g *= $f; $b *= $f;
        } else {
            $r += (255 - $r) * $facteur;
            $g += (255 - $g) * $facteur;
            $b += (255 - $b) * $facteur;
        }

        return sprintf('#%02x%02x%02x',
            (int) max(0, min(255, round($r))),
            (int) max(0, min(255, round($g))),
            (int) max(0, min(255, round($b))));
    }
}

if (!function_exists('date_fr')) {
    /**
     * Formate une date SQL (Y-m-d[ H:i:s]) en format lisible francais "d/m/Y" ou "d/m/Y H:i".
     */
    function date_fr(?string $dateSql, bool $avecHeure = false): string
    {
        if ($dateSql === null || $dateSql === '') {
            return '';
        }
        $ts = strtotime($dateSql);
        if ($ts === false) {
            return $dateSql;
        }
        return date($avecHeure ? 'd/m/Y H:i' : 'd/m/Y', $ts);
    }
}

if (!function_exists('referentiel_icone_chemin')) {
    /** Retourne le chemin SVG correspondant a un referentiel. */
    function referentiel_icone_chemin(string $referentiel): string
    {
        $chemins = [
            'employes'     => '<circle cx="9" cy="7" r="3"/><path d="M3 21v-2a6 6 0 0 1 12 0v2"/><path d="M16 4.5a3 3 0 0 1 0 5.8M18 15a5 5 0 0 1 3 4.5V21"/>',
            'clients'      => '<circle cx="9" cy="8" r="3"/><path d="M3 21v-2a6 6 0 0 1 12 0v2"/><path d="M16 5h5M18.5 2.5v5"/>',
            'fournisseurs' => '<path d="M3 7h18v14H3z"/><path d="M7 7V5a2 2 0 0 1 2-2h6a2 2 0 0 1 2 2v2M3 12h18M9 12v3h6v-3"/>',
            'engins'       => '<path d="M3 17V7h11v10H3z"/><path d="M14 11h4l3 3v3h-7M6 17a2 2 0 1 1-4 0M18 17a2 2 0 1 1-4 0"/>',
            'materiaux'    => '<path d="M4 7l8-4 8 4-8 4-8-4z"/><path d="M4 7v10l8 4 8-4V7M12 11v10"/>',
        ];

        return $chemins[$referentiel] ?? '<circle cx="12" cy="12" r="9"/><path d="M12 8v8M8 12h8"/>';
    }
}
