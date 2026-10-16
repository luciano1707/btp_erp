-- =========================================================
--  Migration 0006 - Achats & Stock (Phase 5)
--  Achats (en-tete + lignes) imputables a un chantier ; reception -> entrees de stock ;
--  mouvements de stock (entrees/sorties/ajustements) par materiau.
--  Montants en Ariary (entiers) ; quantites en DECIMAL(12,3). SQL portable MariaDB/MySQL 8.
-- =========================================================

CREATE TABLE IF NOT EXISTS achats (
    id             INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    reference      VARCHAR(40) NULL UNIQUE,             -- ex: BC-2026-001
    fournisseur_id INT UNSIGNED NULL,
    chantier_id    INT UNSIGNED NULL,                   -- imputation chantier (facultatif)
    date_achat     DATE NULL,
    statut         ENUM('commande','recu','annule') NOT NULL DEFAULT 'commande',
    montant_total  INT UNSIGNED NOT NULL DEFAULT 0,     -- somme des lignes, en Ariary
    notes          VARCHAR(255) NULL,
    cree_par       INT UNSIGNED NULL,
    cree_le        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modifie_le     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_achats_chantier (chantier_id),
    INDEX idx_achats_statut (statut),
    CONSTRAINT fk_achats_fournisseur FOREIGN KEY (fournisseur_id) REFERENCES fournisseurs (id) ON DELETE SET NULL,
    CONSTRAINT fk_achats_chantier    FOREIGN KEY (chantier_id)    REFERENCES chantiers (id)    ON DELETE SET NULL,
    CONSTRAINT fk_achats_auteur      FOREIGN KEY (cree_par)       REFERENCES utilisateurs (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS achat_lignes (
    id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    achat_id      INT UNSIGNED NOT NULL,
    materiau_id   INT UNSIGNED NULL,
    designation   VARCHAR(150) NOT NULL,                -- copie/libre (garde une trace meme si materiau supprime)
    quantite      DECIMAL(12,3) NOT NULL DEFAULT 0,
    prix_unitaire INT UNSIGNED NOT NULL DEFAULT 0,      -- en Ariary
    montant       INT UNSIGNED NOT NULL DEFAULT 0,      -- quantite x prix_unitaire, en Ariary
    CONSTRAINT fk_lignes_achat    FOREIGN KEY (achat_id)    REFERENCES achats (id)    ON DELETE CASCADE,
    CONSTRAINT fk_lignes_materiau FOREIGN KEY (materiau_id) REFERENCES materiaux (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS mouvements_stock (
    id             INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    materiau_id    INT UNSIGNED NOT NULL,
    type           ENUM('entree','sortie','ajustement') NOT NULL,
    quantite       DECIMAL(12,3) NOT NULL DEFAULT 0,    -- toujours positive (le type donne le sens)
    chantier_id    INT UNSIGNED NULL,                   -- sortie imputee a un chantier
    achat_id       INT UNSIGNED NULL,                   -- entree issue d'un achat
    motif          VARCHAR(255) NULL,
    date_mouvement DATE NULL,
    cree_par       INT UNSIGNED NULL,
    cree_le        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_mouvements_materiau (materiau_id),
    INDEX idx_mouvements_chantier (chantier_id),
    CONSTRAINT fk_mouvements_materiau FOREIGN KEY (materiau_id) REFERENCES materiaux (id) ON DELETE CASCADE,
    CONSTRAINT fk_mouvements_chantier FOREIGN KEY (chantier_id) REFERENCES chantiers (id) ON DELETE SET NULL,
    CONSTRAINT fk_mouvements_achat    FOREIGN KEY (achat_id)    REFERENCES achats (id)    ON DELETE SET NULL,
    CONSTRAINT fk_mouvements_auteur   FOREIGN KEY (cree_par)    REFERENCES utilisateurs (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
