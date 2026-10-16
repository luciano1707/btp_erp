<?php

namespace App\Core;

/**
 * Journalisation applicative sur fichier (storage/logs/app-AAAA-MM-JJ.log).
 * Volontairement simple : pas de dependance, compatible hebergement mutualise.
 * NB : distinct du journal d'audit metier (table journal_audit).
 */
final class Logger
{
    /**
     * @param array<string,mixed> $contexte
     */
    public static function ecrire(string $niveau, string $message, array $contexte = []): void
    {
        $dossier = dirname(__DIR__, 2) . '/storage/logs';
        if (!is_dir($dossier)) {
            @mkdir($dossier, 0775, true);
        }

        $fichier = $dossier . '/app-' . date('Y-m-d') . '.log';
        $suffixe = $contexte !== [] ? ' ' . json_encode($contexte, JSON_UNESCAPED_UNICODE) : '';
        $ligne = sprintf("[%s] %s: %s%s\n", date('Y-m-d H:i:s'), strtoupper($niveau), $message, $suffixe);

        @file_put_contents($fichier, $ligne, FILE_APPEND | LOCK_EX);
    }

    public static function info(string $message, array $contexte = []): void
    {
        self::ecrire('info', $message, $contexte);
    }

    public static function avertissement(string $message, array $contexte = []): void
    {
        self::ecrire('warning', $message, $contexte);
    }

    public static function erreur(string $message, array $contexte = []): void
    {
        self::ecrire('error', $message, $contexte);
    }
}
