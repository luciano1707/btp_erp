<?php

namespace App\Models;

use App\Core\Model;

/** Demandes OTP de reinitialisation de mot de passe. */
final class PasswordReset extends Model
{
    protected string $table = 'reinitialisations_mot_de_passe';

    public static function empreinte(string $code): string
    {
        return hash('sha256', $code);
    }

    public function invaliderAnciennes(int $utilisateurId): void
    {
        $this->db()->prepare(
            'UPDATE reinitialisations_mot_de_passe SET utilise = 1 WHERE utilisateur_id = :id AND utilise = 0'
        )->execute([':id' => $utilisateurId]);
    }

    public function aDemandeRecente(string $email, int $secondes = 60): bool
    {
        $req = $this->db()->prepare(
            'SELECT id FROM reinitialisations_mot_de_passe
             WHERE email = :email AND cree_le > :depuis
             LIMIT 1'
        );
        $req->bindValue(':email', strtolower(trim($email)));
        $req->bindValue(':depuis', date('Y-m-d H:i:s', time() - $secondes));
        $req->execute();
        return (bool) $req->fetchColumn();
    }

    public function creerDemande(int $utilisateurId, string $email, string $code, int $expireTimestamp): int
    {
        return $this->creer([
            'utilisateur_id' => $utilisateurId,
            'email' => strtolower(trim($email)),
            'code_hash' => self::empreinte($code),
            'expire_le' => date('Y-m-d H:i:s', $expireTimestamp),
            'tentatives' => 0,
            'utilise' => 0,
        ]);
    }

    /** @return array<string,mixed>|null */
    public function trouverValide(string $email): ?array
    {
        $req = $this->db()->prepare(
            'SELECT * FROM reinitialisations_mot_de_passe
             WHERE email = :email AND utilise = 0 AND expire_le > NOW() AND tentatives < 5
             ORDER BY id DESC LIMIT 1'
        );
        $req->execute([':email' => strtolower(trim($email))]);
        $ligne = $req->fetch();
        return $ligne ?: null;
    }

    public function incrementerTentatives(int $id): void
    {
        $this->db()->prepare(
            'UPDATE reinitialisations_mot_de_passe SET tentatives = tentatives + 1 WHERE id = :id'
        )->execute([':id' => $id]);
    }

    public function marquerUtilise(int $id): void
    {
        $this->db()->prepare(
            'UPDATE reinitialisations_mot_de_passe SET utilise = 1 WHERE id = :id'
        )->execute([':id' => $id]);
    }
}
