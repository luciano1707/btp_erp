<?php

namespace App\Core;

use ErrorException;
use Throwable;

/**
 * Noyau de l'application : configure l'environnement, enregistre les gestionnaires
 * d'erreurs, charge les routes puis traite la requete.
 */
final class App
{
    private Router $router;
    private string $racine;

    public function __construct(string $racine)
    {
        $this->racine = $racine;
        $this->configurer();
        $this->router = new Router();
        $this->chargerRoutes();
    }

    private function configurer(): void
    {
        date_default_timezone_set((string) Env::get('APP_TIMEZONE', 'Indian/Antananarivo'));

        $debug = (bool) Env::get('APP_DEBUG', false);
        error_reporting(E_ALL);
        ini_set('display_errors', $debug ? '1' : '0');

        // Toute erreur PHP devient une exception, centralisant le traitement
        set_error_handler(static function (int $niveau, string $message, string $fichier, int $ligne): bool {
            if (!(error_reporting() & $niveau)) {
                return false;
            }
            throw new ErrorException($message, 0, $niveau, $fichier, $ligne);
        });

        set_exception_handler([$this, 'gererException']);
    }

    private function chargerRoutes(): void
    {
        $api = require $this->racine . '/routes/api.php';
        $web = require $this->racine . '/routes/web.php';
        $api($this->router);
        $web($this->router);
        // Redirection legacy : /pointages -> /chantiers (le pointage se fait par chantier)
        $this->router->get('/pointages', static function (Request $requete): void {
            \App\Core\Response::rediriger(url('/chantiers'));
        });
    }

    public function executer(): void
    {
        $requete = new Request();
        $this->envoyerEntetes($requete);
        $this->router->dispatch($requete);
    }

    /**
     * En-tetes de securite (toutes reponses) et CORS (requetes API, pour le mobile React Native).
     * Repond immediatement aux requetes de pre-verification OPTIONS.
     */
    private function envoyerEntetes(Request $requete): void
    {
        if (headers_sent()) {
            return;
        }

        header('X-Content-Type-Options: nosniff');
        header('X-Frame-Options: DENY');
        header('Referrer-Policy: strict-origin-when-cross-origin');

        if (!$requete->estApi()) {
            return;
        }

        // CORS : on reflete l'origine appelante (mobile / autre front) pour autoriser les cookies.
        $origine = $requete->entete('origin');
        if ($origine !== null && $origine !== '') {
            header("Access-Control-Allow-Origin: $origine");
            header('Access-Control-Allow-Credentials: true');
            header('Vary: Origin');
        } else {
            header('Access-Control-Allow-Origin: *');
        }
        header('Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS');
        header('Access-Control-Allow-Headers: Authorization, Content-Type, Accept');
        header('Access-Control-Max-Age: 86400');

        if ($requete->methode === 'OPTIONS') {
            http_response_code(204);
            exit;
        }
    }

    /** Gestionnaire global d'exceptions : journalise puis repond proprement. */
    public function gererException(Throwable $e): void
    {
        Logger::erreur($e->getMessage(), [
            'exception' => $e::class,
            'fichier'   => $e->getFile(),
            'ligne'     => $e->getLine(),
        ]);

        $debug = (bool) Env::get('APP_DEBUG', false);
        $estApi = str_contains($_SERVER['REQUEST_URI'] ?? '', '/api/');
        $message = $debug ? $e->getMessage() : 'Une erreur interne est survenue.';

        if (headers_sent()) {
            return;
        }

        if ($estApi) {
            Response::erreur(
                $message,
                500,
                $debug ? ['fichier' => $e->getFile(), 'ligne' => $e->getLine()] : null
            );
        }

        http_response_code(500);
        header('Content-Type: text/html; charset=utf-8');
        echo '<!doctype html><html lang="fr"><head><meta charset="utf-8"><title>Erreur serveur</title></head><body>';
        echo '<h1>500 &mdash; Erreur interne du serveur</h1>';
        if ($debug) {
            echo '<pre>' . htmlspecialchars($e->getMessage() . "\n" . $e->getFile() . ':' . $e->getLine()) . '</pre>';
        }
        echo '</body></html>';
    }
}
