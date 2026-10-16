<?php

namespace App\Core;

use RuntimeException;

/**
 * Implementation JWT (HS256) en PHP pur, sans dependance Composer.
 * Choix motive par l'hebergement mutualise Simafri.
 * Utilise pour l'authentification a partir de la Phase 1 (access + refresh tokens).
 */
final class Jwt
{
    /**
     * Genere un token signe.
     *
     * @param array<string,mixed> $charge Donnees applicatives (ex: ['sub' => 12, 'role' => 'directeur'])
     * @param int    $ttl  Duree de validite en secondes
     * @param string $type Type de token ('access' ou 'refresh')
     */
    public static function encoder(array $charge, int $ttl, string $type = 'access'): string
    {
        $entete = ['alg' => 'HS256', 'typ' => 'JWT'];
        $maintenant = time();

        $charge = array_merge($charge, [
            'iss'  => Env::get('JWT_ISSUER', 'btp-erp'),
            'iat'  => $maintenant,
            'exp'  => $maintenant + $ttl,
            'type' => $type,
            // Identifiant unique du token : garantit l'unicite meme pour deux tokens
            // emis a la meme seconde pour le meme utilisateur (evite les collisions de hash).
            'jti'  => bin2hex(random_bytes(16)),
        ]);

        $segEntete = self::base64UrlEncode(json_encode($entete, JSON_UNESCAPED_UNICODE));
        $segCharge = self::base64UrlEncode(json_encode($charge, JSON_UNESCAPED_UNICODE));
        $signature = self::signer("$segEntete.$segCharge");

        return "$segEntete.$segCharge.$signature";
    }

    /**
     * Verifie et decode un token. Leve une exception si invalide ou expire.
     *
     * @return array<string,mixed> La charge utile
     */
    public static function decoder(string $token): array
    {
        $parties = explode('.', $token);
        if (count($parties) !== 3) {
            throw new RuntimeException('Token JWT malforme.');
        }

        [$segEntete, $segCharge, $signature] = $parties;

        $signatureAttendue = self::signer("$segEntete.$segCharge");
        if (!hash_equals($signatureAttendue, $signature)) {
            throw new RuntimeException('Signature JWT invalide.');
        }

        $charge = json_decode(self::base64UrlDecode($segCharge), true);
        if (!is_array($charge)) {
            throw new RuntimeException('Charge JWT illisible.');
        }

        if (isset($charge['exp']) && time() >= (int) $charge['exp']) {
            throw new RuntimeException('Token expire.');
        }

        return $charge;
    }

    /** Signature HMAC-SHA256 encodee en base64url. */
    private static function signer(string $donnees): string
    {
        $secret = (string) Env::get('JWT_SECRET', '');
        if ($secret === '') {
            throw new RuntimeException('JWT_SECRET non defini.');
        }
        return self::base64UrlEncode(hash_hmac('sha256', $donnees, $secret, true));
    }

    private static function base64UrlEncode(string $donnees): string
    {
        return rtrim(strtr(base64_encode($donnees), '+/', '-_'), '=');
    }

    private static function base64UrlDecode(string $donnees): string
    {
        return (string) base64_decode(strtr($donnees, '-_', '+/'));
    }
}
