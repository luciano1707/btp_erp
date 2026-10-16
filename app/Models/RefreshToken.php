<?php

namespace App\Models;

use App\Core\Model;

/**
 * Modele des jetons de rafraichissement.
 * Les tokens ne sont jamais stockes en clair : on conserve leur empreinte SHA-256.
 */
final class RefreshToken extends Model
{
    protected string $table = 'refresh_tokens';

    /** Empreinte SHA-256 d'un token (pour stockage / recherche). */
    public static function empreinte(string $token): string
    {
        return hash('sha256', $token);
    }

    /** Enregistre un nouveau refresh token pour un utilisateur. */
    public function enregistrer(int $utilisateurId, string $token, int $expireTimestamp): int
    {
        return $this->creer([
            'utilisateur_id' => $utilisateurId,
            'token_hash'     => self::empreinte($token),
            'expire_le'      => date('Y-m-d H:i:s', $expireTimestamp),
            'revoque'        => 0,
        ]);
    }

    /** Retrouve un token valide (non revoque, non expire) par sa valeur. @return array<string,mixed>|null */
    public function trouverValide(string $token): ?array
    {
        $req = $this->db()->prepare(
            'SELECT * FROM refresh_tokens
             WHERE token_hash = :h AND revoque = 0 AND expire_le > NOW()
             LIMIT 1'
        );
        $req->execute([':h' => self::empreinte($token)]);
        $ligne = $req->fetch();
        return $ligne ?: null;
    }

    /** Revoque un token (par sa valeur). */
    public function revoquer(string $token): void
    {
        $this->db()->prepare('UPDATE refresh_tokens SET revoque = 1 WHERE token_hash = :h')
            ->execute([':h' => self::empreinte($token)]);
    }

    /** Revoque tous les tokens d'un utilisateur (ex: deconnexion globale). */
    public function revoquerTous(int $utilisateurId): void
    {
        $this->db()->prepare('UPDATE refresh_tokens SET revoque = 1 WHERE utilisateur_id = :id')
            ->execute([':id' => $utilisateurId]);
    }

    /** Purge les tokens expires ou revoques (a appeler via cron). */
    public function purger(): int
    {
        $req = $this->db()->query('DELETE FROM refresh_tokens WHERE expire_le < NOW() OR revoque = 1');
        return $req->rowCount();
    }
}
