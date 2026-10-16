<?php

namespace App\Models;

use App\Core\Model;
use PDO;

/**
 * Modele des comptes utilisateurs de l'ERP.
 */
final class Utilisateur extends Model
{
    protected string $table = 'utilisateurs';

    /** Roles autorises (doit correspondre a l'ENUM SQL). */
    public const ROLES = ['directeur', 'chef_chantier', 'comptable', 'magasinier'];

    /** Recherche un utilisateur par email. @return array<string,mixed>|null */
    public function trouverParEmail(string $email): ?array
    {
        $req = $this->db()->prepare('SELECT * FROM utilisateurs WHERE email = :email LIMIT 1');
        $req->execute([':email' => strtolower(trim($email))]);
        $ligne = $req->fetch();
        return $ligne ?: null;
    }

    /** Met a jour l'horodatage de derniere connexion. */
    public function marquerConnexion(int $id): void
    {
        $this->db()->prepare('UPDATE utilisateurs SET derniere_connexion = NOW() WHERE id = :id')
            ->execute([':id' => $id]);
    }

    /** Change le mot de passe (hash) et leve le drapeau doit_changer_mdp. */
    public function definirMotDePasse(int $id, string $hash): void
    {
        $this->db()->prepare(
            'UPDATE utilisateurs SET mot_de_passe = :h, doit_changer_mdp = 0 WHERE id = :id'
        )->execute([':h' => $hash, ':id' => $id]);
    }

    /** Met a jour uniquement les informations personnelles d'un utilisateur. */
    public function definirProfil(int $id, string $nom, string $prenom, string $email, ?string $telephone): void
    {
        $this->db()->prepare(
            'UPDATE utilisateurs SET nom = :nom, prenom = :prenom, email = :email, telephone = :telephone WHERE id = :id'
        )->execute([
            ':nom' => $nom, ':prenom' => $prenom, ':email' => strtolower(trim($email)),
            ':telephone' => $telephone !== '' ? $telephone : null, ':id' => $id,
        ]);
    }

    /**
     * Version publique d'un utilisateur (sans le hash du mot de passe),
     * telle que renvoyee par l'API.
     *
     * @param array<string,mixed> $u
     * @return array<string,mixed>
     */
    public static function versPublic(array $u): array
    {
        return [
            'id'               => (int) $u['id'],
            'nom'              => $u['nom'],
            'prenom'           => $u['prenom'],
            'email'            => $u['email'],
            'telephone'        => $u['telephone'] ?? null,
            'role'             => $u['role'],
            'actif'            => (bool) $u['actif'],
            'doit_changer_mdp' => (bool) $u['doit_changer_mdp'],
        ];
    }
}
