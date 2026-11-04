<?php

namespace App\Models;

use App\Core\Database;
use App\Core\Logger;
use App\Core\NotificationDelivery;
use PDO;

final class Notification
{
    /** @return array<int,array<string,mixed>> */
    public function listePour(int $utilisateurId, bool $nonLuesSeulement = false, int $limite = 100): array
    {
        $pdo = Database::connexion();
        $sql = 'SELECT * FROM notifications WHERE utilisateur_id = :uid';
        if ($nonLuesSeulement) {
            $sql .= ' AND lu = 0';
        }
        $sql .= ' ORDER BY cree_le DESC, id DESC LIMIT :limite';
        $stmt = $pdo->prepare($sql);
        $stmt->bindValue(':uid', $utilisateurId, PDO::PARAM_INT);
        $stmt->bindValue(':limite', $limite, PDO::PARAM_INT);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function compterNonLues(int $utilisateurId): int
    {
        $stmt = Database::connexion()->prepare('SELECT COUNT(*) FROM notifications WHERE utilisateur_id = :uid AND lu = 0');
        $stmt->execute(['uid' => $utilisateurId]);
        return (int) $stmt->fetchColumn();
    }

    public function marquerLue(int $id, int $utilisateurId): bool
    {
        $stmt = Database::connexion()->prepare('UPDATE notifications
            SET lu = 1, lu_le = :date
            WHERE id = :id AND utilisateur_id = :uid');
        return $stmt->execute([
            'date' => date('Y-m-d H:i:s'),
            'id'   => $id,
            'uid'  => $utilisateurId,
        ]);
    }

    public function toutLire(int $utilisateurId): int
    {
        $stmt = Database::connexion()->prepare('UPDATE notifications
            SET lu = 1, lu_le = :date
            WHERE utilisateur_id = :uid AND lu = 0');
        $stmt->execute(['date' => date('Y-m-d H:i:s'), 'uid' => $utilisateurId]);
        return $stmt->rowCount();
    }

    public static function creer(
        int $utilisateurId,
        string $type,
        string $titre,
        string $message,
        ?string $lien = null
    ): void {
        try {
            $stmt = Database::connexion()->prepare('INSERT INTO notifications
                (utilisateur_id, type, titre, message, lien)
                VALUES (:uid, :type, :titre, :message, :lien)');
            $stmt->execute([
                'uid'     => $utilisateurId,
                'type'    => mb_substr($type, 0, 50),
                'titre'   => mb_substr($titre, 0, 150),
                'message' => $message,
                'lien'    => $lien,
            ]);
        } catch (\Throwable $e) {
            Logger::erreur('Impossible d enregistrer une notification interne.', [
                'utilisateur_id' => $utilisateurId,
                'erreur' => $e->getMessage(),
            ]);
            return;
        }
        NotificationDelivery::envoyer($utilisateurId, $titre, $message, $lien);
    }

    /**
     * Notifie tous les utilisateurs actifs ayant l'un des roles donnes.
     *
     * @param string[] $roles
     */
    public static function pourRoles(
        array $roles,
        string $type,
        string $titre,
        string $message,
        ?string $lien = null
    ): void {
        self::pourRolesSauf($roles, 0, $type, $titre, $message, $lien);
    }

    /**
     * Notifie les utilisateurs d'un role en excluant un utilisateur (ex: l'auteur,
     * qui ne doit jamais s'auto-valider).
     *
     * @param string[] $roles
     */
    public static function pourRolesSauf(
        array $roles,
        int $exclureUtilisateurId,
        string $type,
        string $titre,
        string $message,
        ?string $lien = null
    ): void {
        if ($roles === []) {
            return;
        }
        try {
            $placeholders = [];
            $params = [];
            foreach (array_values($roles) as $i => $role) {
                $placeholders[] = ":role$i";
                $params["role$i"] = $role;
            }
            $sql = 'SELECT id FROM utilisateurs WHERE actif = 1 AND role IN (' . implode(', ', $placeholders) . ')';
            $stmt = Database::connexion()->prepare($sql);
            $stmt->execute($params);
            foreach ($stmt->fetchAll(PDO::FETCH_COLUMN) as $uid) {
                if ($exclureUtilisateurId > 0 && (int) $uid === $exclureUtilisateurId) {
                    continue;
                }
                self::creer((int) $uid, $type, $titre, $message, $lien);
            }
        } catch (\Throwable $e) {
            // Idem : la notification est accessoire.
        }
    }
}
