-- =========================================================
--  Migration 0007 - Devis & Facturation (Phase 6)
--  Devis (en-tete + lignes) -> Facture -> Paiements.
--  Montants en Ariary (entiers) ; TVA en pourcentage. SQL portable MariaDB/MySQL 8.
-- =========================================================

CREATE TABLE IF NOT EXISTS devis (
    id           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    reference    VARCHAR(40) NULL UNIQUE,
    client_id    INT UNSIGNED NULL,
    chantier_id  INT UNSIGNED NULL,
    date_devis   DATE NULL,
    validite     DATE NULL,
    statut       ENUM('brouillon','envoye','accepte','refuse') NOT NULL DEFAULT 'brouillon',
    montant_ht   INT UNSIGNED NOT NULL DEFAULT 0,
    tva_taux     DECIMAL(5,2) NOT NULL DEFAULT 20.00,
    montant_tva  INT UNSIGNED NOT NULL DEFAULT 0,
    montant_ttc  INT UNSIGNED NOT NULL DEFAULT 0,
    notes        VARCHAR(255) NULL,
    cree_par     INT UNSIGNED NULL,
    cree_le      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modifie_le   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_devis_client (client_id),
    INDEX idx_devis_statut (statut),
    CONSTRAINT fk_devis_client   FOREIGN KEY (client_id)   REFERENCES clients (id)      ON DELETE SET NULL,
    CONSTRAINT fk_devis_chantier FOREIGN KEY (chantier_id) REFERENCES chantiers (id)    ON DELETE SET NULL,
    CONSTRAINT fk_devis_auteur   FOREIGN KEY (cree_par)    REFERENCES utilisateurs (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS devis_lignes (
    id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    devis_id      INT UNSIGNED NOT NULL,
    designation   VARCHAR(200) NOT NULL,
    quantite      DECIMAL(12,3) NOT NULL DEFAULT 1,
    prix_unitaire INT UNSIGNED NOT NULL DEFAULT 0,
    montant       INT UNSIGNED NOT NULL DEFAULT 0,
    CONSTRAINT fk_devislignes_devis FOREIGN KEY (devis_id) REFERENCES devis (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS factures (
    id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    reference     VARCHAR(40) NULL UNIQUE,
    devis_id      INT UNSIGNED NULL,
    client_id     INT UNSIGNED NULL,
    chantier_id   INT UNSIGNED NULL,
    date_facture  DATE NULL,
    echeance      DATE NULL,
    statut        ENUM('brouillon','emise','payee_partiel','payee','annulee') NOT NULL DEFAULT 'brouillon',
    montant_ht    INT UNSIGNED NOT NULL DEFAULT 0,
    tva_taux      DECIMAL(5,2) NOT NULL DEFAULT 20.00,
    montant_tva   INT UNSIGNED NOT NULL DEFAULT 0,
    montant_ttc   INT UNSIGNED NOT NULL DEFAULT 0,
    montant_paye  INT UNSIGNED NOT NULL DEFAULT 0,
    notes         VARCHAR(255) NULL,
    cree_par      INT UNSIGNED NULL,
    cree_le       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modifie_le    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_factures_client (client_id),
    INDEX idx_factures_statut (statut),
    CONSTRAINT fk_factures_devis    FOREIGN KEY (devis_id)    REFERENCES devis (id)        ON DELETE SET NULL,
    CONSTRAINT fk_factures_client   FOREIGN KEY (client_id)   REFERENCES clients (id)      ON DELETE SET NULL,
    CONSTRAINT fk_factures_chantier FOREIGN KEY (chantier_id) REFERENCES chantiers (id)    ON DELETE SET NULL,
    CONSTRAINT fk_factures_auteur   FOREIGN KEY (cree_par)    REFERENCES utilisateurs (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS facture_lignes (
    id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    facture_id    INT UNSIGNED NOT NULL,
    designation   VARCHAR(200) NOT NULL,
    quantite      DECIMAL(12,3) NOT NULL DEFAULT 1,
    prix_unitaire INT UNSIGNED NOT NULL DEFAULT 0,
    montant       INT UNSIGNED NOT NULL DEFAULT 0,
    CONSTRAINT fk_facturelignes_facture FOREIGN KEY (facture_id) REFERENCES factures (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS paiements (
    id                 INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    facture_id         INT UNSIGNED NOT NULL,
    date_paiement      DATE NULL,
    montant            INT UNSIGNED NOT NULL DEFAULT 0,
    mode               ENUM('especes','cheque','virement','mobile_money','autre') NOT NULL DEFAULT 'especes',
    reference_paiement VARCHAR(80) NULL,
    cree_par           INT UNSIGNED NULL,
    cree_le            TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_paiements_facture (facture_id),
    CONSTRAINT fk_paiements_facture FOREIGN KEY (facture_id) REFERENCES factures (id)     ON DELETE CASCADE,
    CONSTRAINT fk_paiements_auteur  FOREIGN KEY (cree_par)   REFERENCES utilisateurs (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
