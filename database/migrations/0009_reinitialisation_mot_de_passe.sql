-- =========================================================
-- Migration 0009 - OTP de reinitialisation du mot de passe
-- =========================================================

CREATE TABLE IF NOT EXISTS reinitialisations_mot_de_passe (
    id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    utilisateur_id INT UNSIGNED NOT NULL,
    email          VARCHAR(190) NOT NULL,
    code_hash      CHAR(64) NOT NULL,
    expire_le      TIMESTAMP NOT NULL,
    tentatives     TINYINT UNSIGNED NOT NULL DEFAULT 0,
    utilise        TINYINT(1) NOT NULL DEFAULT 0,
    cree_le        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_reset_email (email, utilise, expire_le),
    INDEX idx_reset_utilisateur (utilisateur_id),
    CONSTRAINT fk_reset_utilisateur
        FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
