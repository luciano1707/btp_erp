<?php

namespace App\Core;

/**
 * Fabrique de reponses HTTP.
 * L'enveloppe JSON est standardisee pour etre consommee a l'identique par le web et le mobile :
 *   Succes : { "succes": true,  "message": "...", "donnees": ... }
 *   Erreur : { "succes": false, "message": "...", "erreurs": ... }
 */
final class Response
{
    /**
     * Envoie une reponse JSON brute et termine le script.
     *
     * @param array<string,string> $entetes
     */
    public static function json(mixed $donnees, int $statut = 200, array $entetes = []): never
    {
        if (!headers_sent()) {
            http_response_code($statut);
            header('Content-Type: application/json; charset=utf-8');
            foreach ($entetes as $nom => $valeur) {
                header("$nom: $valeur");
            }
        }
        echo json_encode($donnees, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        exit;
    }

    /** Reponse de succes standardisee. */
    public static function succes(mixed $donnees = null, string $message = 'OK', int $statut = 200): never
    {
        self::json([
            'succes'  => true,
            'message' => $message,
            'donnees' => $donnees,
        ], $statut);
    }

    /** Reponse d'erreur standardisee. */
    public static function erreur(string $message, int $statut = 400, mixed $erreurs = null): never
    {
        $charge = [
            'succes'  => false,
            'message' => $message,
        ];
        if ($erreurs !== null) {
            $charge['erreurs'] = $erreurs;
        }
        self::json($charge, $statut);
    }

    /** Rend une vue HTML et termine le script. */
    public static function vue(string $vue, array $donnees = [], int $statut = 200): never
    {
        if (!headers_sent()) {
            http_response_code($statut);
        }
        View::rendre($vue, $donnees);
        exit;
    }

    /** Redirige vers une URL. */
    public static function rediriger(string $url, int $statut = 302): never
    {
        if (!headers_sent()) {
            http_response_code($statut);
            header("Location: $url");
        }
        exit;
    }
}
