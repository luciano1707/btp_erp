-- =========================================================
--  Migration 0002 - Authentification & RBAC (Phase 1)
--  Tables : utilisateurs + jetons de rafraichissement (refresh tokens).
--  SQL portable MariaDB 10.4 / MySQL 8.
-- =========================================================

-- Comptes utilisateurs de l'ERP
CREATE TABLE IF NOT EXISTS utilisateurs (
    id                INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nom               VARCHAR(100) NOT NULL,
    prenom            VARCHAR(100) NULL,
    email             VARCHAR(190) NOT NULL UNIQUE,
    telephone         VARCHAR(30) NULL,
    mot_de_passe      VARCHAR(255) NOT NULL,          -- hash bcrypt (password_hash)
    role              ENUM('directeur','chef_chantier','comptable','magasinier') NOT NULL DEFAULT 'chef_chantier',
    actif             TINYINT(1) NOT NULL DEFAULT 1,
    doit_changer_mdp  TINYINT(1) NOT NULL DEFAULT 0,  -- force le changement a la 1ere connexion
    derniere_connexion TIMESTAMP NULL,
    cree_le           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modifie_le        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_utilisateurs_role (role),
    INDEX idx_utilisateurs_actif (actif)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Jetons de rafraichissement : stockes hashes pour permettre la revocation (logout)
-- et la rotation a chaque rafraichissement.
CREATE TABLE IF NOT EXISTS refresh_tokens (
    id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    utilisateur_id INT UNSIGNED NOT NULL,
    token_hash     CHAR(64) NOT NULL,                -- sha256 du refresh token
    expire_le      TIMESTAMP NOT NULL,
    revoque        TINYINT(1) NOT NULL DEFAULT 0,
    cree_le        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_refresh_hash (token_hash),
    INDEX idx_refresh_utilisateur (utilisateur_id),
    CONSTRAINT fk_refresh_utilisateur
        FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
