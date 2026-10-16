-- =========================================================
--  Migration 0008 - Montants en BIGINT (correctif)
--  INT UNSIGNED plafonne a ~4,29 milliards : insuffisant pour l'Ariary
--  (marches BTP de plusieurs milliards, ex: 12,3 Md). On passe les colonnes
--  monetaires en BIGINT UNSIGNED. Portable MariaDB / MySQL 8.
-- =========================================================

ALTER TABLE chantiers    MODIFY COLUMN budget_previsionnel BIGINT UNSIGNED NULL;
ALTER TABLE lots         MODIFY COLUMN budget_previsionnel BIGINT UNSIGNED NULL;

ALTER TABLE achats       MODIFY COLUMN montant_total  BIGINT UNSIGNED NOT NULL DEFAULT 0;
ALTER TABLE achat_lignes MODIFY COLUMN prix_unitaire  BIGINT UNSIGNED NOT NULL DEFAULT 0;
ALTER TABLE achat_lignes MODIFY COLUMN montant        BIGINT UNSIGNED NOT NULL DEFAULT 0;

ALTER TABLE devis        MODIFY COLUMN montant_ht   BIGINT UNSIGNED NOT NULL DEFAULT 0;
ALTER TABLE devis        MODIFY COLUMN montant_tva  BIGINT UNSIGNED NOT NULL DEFAULT 0;
ALTER TABLE devis        MODIFY COLUMN montant_ttc  BIGINT UNSIGNED NOT NULL DEFAULT 0;
ALTER TABLE devis_lignes MODIFY COLUMN prix_unitaire BIGINT UNSIGNED NOT NULL DEFAULT 0;
ALTER TABLE devis_lignes MODIFY COLUMN montant       BIGINT UNSIGNED NOT NULL DEFAULT 0;

ALTER TABLE factures       MODIFY COLUMN montant_ht   BIGINT UNSIGNED NOT NULL DEFAULT 0;
ALTER TABLE factures       MODIFY COLUMN montant_tva  BIGINT UNSIGNED NOT NULL DEFAULT 0;
ALTER TABLE factures       MODIFY COLUMN montant_ttc  BIGINT UNSIGNED NOT NULL DEFAULT 0;
ALTER TABLE factures       MODIFY COLUMN montant_paye BIGINT UNSIGNED NOT NULL DEFAULT 0;
ALTER TABLE facture_lignes MODIFY COLUMN prix_unitaire BIGINT UNSIGNED NOT NULL DEFAULT 0;
ALTER TABLE facture_lignes MODIFY COLUMN montant       BIGINT UNSIGNED NOT NULL DEFAULT 0;

ALTER TABLE paiements MODIFY COLUMN montant BIGINT UNSIGNED NOT NULL DEFAULT 0;
