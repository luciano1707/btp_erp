-- =========================================================
--  Migration 0004 - Chantiers & Lots (Phase 3)
--  Un chantier (batiment / route) se decoupe en lots.
--  Montants en Ariary (entiers). SQL portable MariaDB/MySQL 8.
-- =========================================================

CREATE TABLE IF NOT EXISTS chantiers (
    id                  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code                VARCHAR(30) NULL UNIQUE,             -- ex: CH-2026-001
    nom                 VARCHAR(150) NOT NULL,
    type                ENUM('batiment','route','autre') NOT NULL DEFAULT 'batiment',
    client_id           INT UNSIGNED NULL,
    responsable_id      INT UNSIGNED NULL,                   -- chef de chantier (utilisateur)
    localisation        VARCHAR(255) NULL,                   -- lieu du chantier
    date_debut          DATE NULL,
    date_fin_prevue     DATE NULL,
    date_fin_reelle     DATE NULL,
    budget_previsionnel INT UNSIGNED NULL,                   -- en Ariary
    statut              ENUM('planifie','en_cours','suspendu','termine','annule') NOT NULL DEFAULT 'planifie',
    description         TEXT NULL,
    actif               TINYINT(1) NOT NULL DEFAULT 1,
    cree_le             TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modifie_le          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_chantiers_statut (statut),
    INDEX idx_chantiers_nom (nom),
    CONSTRAINT fk_chantiers_client
        FOREIGN KEY (client_id) REFERENCES clients (id) ON DELETE SET NULL,
    CONSTRAINT fk_chantiers_responsable
        FOREIGN KEY (responsable_id) REFERENCES utilisateurs (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Lots : decoupage d'un chantier (ex: terrassement, fondations, bitume)
CREATE TABLE IF NOT EXISTS lots (
    id                  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    chantier_id         INT UNSIGNED NOT NULL,
    nom                 VARCHAR(150) NOT NULL,
    budget_previsionnel INT UNSIGNED NULL,                   -- en Ariary
    avancement          TINYINT UNSIGNED NOT NULL DEFAULT 0, -- pourcentage 0-100 (auto en Phase 7)
    statut              ENUM('a_faire','en_cours','termine') NOT NULL DEFAULT 'a_faire',
    ordre               INT NOT NULL DEFAULT 0,
    cree_le             TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modifie_le          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_lots_chantier (chantier_id),
    CONSTRAINT fk_lots_chantier
        FOREIGN KEY (chantier_id) REFERENCES chantiers (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
