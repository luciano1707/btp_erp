<?php

namespace App\Core;

use PDO;
use PDOException;
use RuntimeException;

/**
 * Point d'acces unique a la base de donnees (patron singleton).
 * Utilise PDO en mode exceptions, requetes preparees reelles (pas d'emulation).
 */
final class Database
{
    private static ?PDO $instance = null;

    /** Empeche l'instanciation directe. */
    private function __construct()
    {
    }

    /**
     * Retourne la connexion PDO partagee vers la base applicative.
     */
    public static function connexion(): PDO
    {
        if (self::$instance instanceof PDO) {
            return self::$instance;
        }

        $hote    = Env::get('DB_HOST', '127.0.0.1');
        $port    = Env::get('DB_PORT', '3306');
        $base    = Env::get('DB_NAME', 'btp_erp');
        $charset = Env::get('DB_CHARSET', 'utf8mb4');

        $dsn = "mysql:host=$hote;port=$port;dbname=$base;charset=$charset";

        try {
            self::$instance = new PDO(
                $dsn,
                (string) Env::get('DB_USER', 'root'),
                (string) Env::get('DB_PASS', ''),
                [
                    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES   => false,
                ]
            );
        } catch (PDOException $e) {
            throw new RuntimeException('Connexion a la base de donnees echouee : ' . $e->getMessage(), 0, $e);
        }

        return self::$instance;
    }

    /**
     * Connexion au serveur SANS selectionner de base.
     * Utile pour creer la base lors des migrations initiales.
     */
    public static function connexionServeur(): PDO
    {
        $hote    = Env::get('DB_HOST', '127.0.0.1');
        $port    = Env::get('DB_PORT', '3306');
        $charset = Env::get('DB_CHARSET', 'utf8mb4');

        $dsn = "mysql:host=$hote;port=$port;charset=$charset";

        return new PDO(
            $dsn,
            (string) Env::get('DB_USER', 'root'),
            (string) Env::get('DB_PASS', ''),
            [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
        );
    }
}
