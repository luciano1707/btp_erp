-- =========================================================
--  Migration 0001 - Socle applicatif (Phase 0)
--  Tables transverses : parametres + journal d'audit.
--  SQL portable MariaDB 10.4 / MySQL 8.
-- =========================================================

-- Parametres generaux de l'application (cle / valeur)
CREATE TABLE IF NOT EXISTS parametres (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    cle         VARCHAR(100) NOT NULL UNIQUE,
    valeur      TEXT NULL,
    description VARCHAR(255) NULL,
    cree_le     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modifie_le  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Journal d'audit : tracabilite de chaque action (exigence de transparence totale)
CREATE TABLE IF NOT EXISTS journal_audit (
    id                BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    utilisateur_id    INT UNSIGNED NULL,
    action            VARCHAR(100) NOT NULL,
    entite            VARCHAR(100) NULL,
    entite_id         VARCHAR(64) NULL,
    details           JSON NULL,
    adresse_ip        VARCHAR(45) NULL,
    agent_utilisateur VARCHAR(255) NULL,
    cree_le           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_journal_utilisateur (utilisateur_id),
    INDEX idx_journal_entite (entite, entite_id),
    INDEX idx_journal_date (cree_le)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Valeurs de parametres par defaut
INSERT INTO parametres (cle, valeur, description) VALUES
    ('devise', 'Ar', 'Symbole de la devise (Ariary)'),
    ('entreprise_nom', 'Mon Entreprise BTP', 'Nom de l''entreprise'),
    ('entreprise_ville', 'Mahajanga', 'Ville du siege')
ON DUPLICATE KEY UPDATE cle = cle;
