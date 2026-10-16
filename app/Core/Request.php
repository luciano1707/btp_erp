<?php

namespace App\Core;

/**
 * Represente la requete HTTP entrante.
 * Normalise methode, chemin, entetes, parametres de requete et corps (JSON ou formulaire).
 */
final class Request
{
    /** Methode HTTP (GET, POST, PUT, DELETE, PATCH). */
    public string $methode;

    /** Chemin normalise, sans le sous-dossier de base (ex: /api/v1/health). */
    public string $chemin;

    /** Parametres d'URL extraits par le routeur (ex: {id}). @var array<string,string> */
    public array $params = [];

    /** Charge utile du JWT, injectee par le middleware d'authentification. */
    public ?array $auth = null;

    /** @var array<string,mixed> */
    private array $requete;

    /** @var array<string,mixed> */
    private array $corps;

    /** @var array<string,string> */
    private array $entetes;

    public function __construct()
    {
        $this->methode = strtoupper($_SERVER['REQUEST_METHOD'] ?? 'GET');
        $this->chemin  = $this->extraireChemin();
        $this->requete = $_GET;
        $this->entetes = $this->extraireEntetes();
        $this->corps   = $this->extraireCorps();
    }

    /**
     * Extrait le chemin en retirant le sous-dossier ou reside index.php
     * (ex: /BTP_ERP/public), afin d'obtenir des routes propres (/api/v1/...).
     */
    private function extraireChemin(): string
    {
        $uri    = $_SERVER['REQUEST_URI'] ?? '/';
        $chemin = parse_url($uri, PHP_URL_PATH) ?: '/';

        $base = rtrim(str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME'] ?? '')), '/');
        if ($base !== '' && $base !== '/' && str_starts_with($chemin, $base)) {
            $chemin = substr($chemin, strlen($base));
        }

        $chemin = '/' . trim($chemin, '/');
        return $chemin;
    }

    /** @return array<string,string> */
    private function extraireEntetes(): array
    {
        $entetes = [];
        if (function_exists('getallheaders')) {
            foreach (getallheaders() as $nom => $valeur) {
                $entetes[strtolower($nom)] = $valeur;
            }
            return $entetes;
        }

        // Repli si getallheaders() indisponible (certains SAPI)
        foreach ($_SERVER as $cle => $valeur) {
            if (str_starts_with($cle, 'HTTP_')) {
                $nom = strtolower(str_replace('_', '-', substr($cle, 5)));
                $entetes[$nom] = $valeur;
            }
        }
        return $entetes;
    }

    /** @return array<string,mixed> */
    private function extraireCorps(): array
    {
        $type = $this->entetes['content-type'] ?? '';

        if (str_contains($type, 'application/json')) {
            $brut = file_get_contents('php://input') ?: '';
            $decode = json_decode($brut, true);
            return is_array($decode) ? $decode : [];
        }

        return $_POST;
    }

    /** Valeur d'un champ du corps de requete. */
    public function input(string $cle, mixed $defaut = null): mixed
    {
        return $this->corps[$cle] ?? $defaut;
    }

    /** Ensemble des champs du corps de requete. @return array<string,mixed> */
    public function tout(): array
    {
        return $this->corps;
    }

    /** Valeur d'un parametre de la chaine de requete (?cle=valeur). */
    public function query(string $cle, mixed $defaut = null): mixed
    {
        return $this->requete[$cle] ?? $defaut;
    }

    /** Valeur d'un entete HTTP (nom insensible a la casse). */
    public function entete(string $nom, ?string $defaut = null): ?string
    {
        return $this->entetes[strtolower($nom)] ?? $defaut;
    }

    /** Extrait le token Bearer de l'entete Authorization, s'il existe. */
    public function tokenBearer(): ?string
    {
        $auth = $this->entete('authorization', '');
        if ($auth !== null && preg_match('/^Bearer\s+(.+)$/i', $auth, $m)) {
            return trim($m[1]);
        }
        return null;
    }

    /**
     * Token passe en parametre d'URL (?jeton=...).
     * Reserve aux pages HTML ouvertes depuis une nouvelle fenetre (impression, PDF) :
     * ces navigations ne peuvent pas porter l'entete Authorization, et le client mobile/web
     * conserve le jeton uniquement en memoire. Le jeton reste un access token court duree.
     */
    public function jetonUrl(): ?string
    {
        $jeton = $this->requete['jeton'] ?? null;
        return is_string($jeton) && $jeton !== '' ? $jeton : null;
    }

    /** Valeur d'un cookie. */
    public function cookie(string $nom, ?string $defaut = null): ?string
    {
        return $_COOKIE[$nom] ?? $defaut;
    }

    /** Adresse IP du client (prend en compte un eventuel proxy). */
    public function ip(): string
    {
        return $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '0.0.0.0';
    }

    /** Indique si la requete cible l'API (prefixe /api/). */
    public function estApi(): bool
    {
        return str_starts_with($this->chemin, '/api/');
    }
}
