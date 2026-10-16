<?php

namespace App\Core;

use Throwable;

/**
 * Journal d'audit metier : trace chaque action significative (exigence de transparence totale).
 * Ecrit dans la table journal_audit. A appeler depuis les controleurs a chaque
 * creation / modification / suppression / mouvement financier.
 */
final class Audit
{
    /**
     * Enregistre une entree d'audit.
     *
     * @param string               $action        Ex: 'connexion', 'chantier.creation', 'facture.paiement'
     * @param string|null          $entite        Nom logique de l'entite concernee (ex: 'chantier')
     * @param int|string|null      $entiteId      Identifiant de l'entite concernee
     * @param array<string,mixed>  $details       Contexte libre (anciennes/nouvelles valeurs, montant, etc.)
     * @param int|null             $utilisateurId Auteur de l'action (null si systeme / non authentifie)
     */
    public static function enregistrer(
        string $action,
        ?string $entite = null,
        int|string|null $entiteId = null,
        array $details = [],
        ?int $utilisateurId = null
    ): void {
        try {
            $sql = 'INSERT INTO journal_audit
                        (utilisateur_id, action, entite, entite_id, details, adresse_ip, agent_utilisateur)
                    VALUES
                        (:utilisateur_id, :action, :entite, :entite_id, :details, :ip, :agent)';

            Database::connexion()->prepare($sql)->execute([
                ':utilisateur_id' => $utilisateurId,
                ':action'         => $action,
                ':entite'         => $entite,
                ':entite_id'      => $entiteId !== null ? (string) $entiteId : null,
                ':details'        => $details !== [] ? json_encode($details, JSON_UNESCAPED_UNICODE) : null,
                ':ip'             => $_SERVER['REMOTE_ADDR'] ?? null,
                ':agent'          => substr($_SERVER['HTTP_USER_AGENT'] ?? '', 0, 255) ?: null,
            ]);
        } catch (Throwable $e) {
            // L'audit ne doit jamais casser le flux metier : on se contente de journaliser l'echec.
            Logger::erreur("Echec ecriture journal_audit : " . $e->getMessage(), ['action' => $action]);
        }
    }
}
