-- =========================================================
--  Migration 0005 - Pointage & main d'oeuvre (Phase 4)
--  Feuille de pointage journaliere : presence par employe et par jour,
--  cout de main d'oeuvre impute au chantier (et au lot).
--  Cout fige a la saisie (en Ariary). SQL portable MariaDB/MySQL 8.
-- =========================================================

CREATE TABLE IF NOT EXISTS pointages (
    id             INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    chantier_id    INT UNSIGNED NOT NULL,
    lot_id         INT UNSIGNED NULL,
    employe_id     INT UNSIGNED NOT NULL,
    date_pointage  DATE NOT NULL,
    type_presence  ENUM('journee','demi_journee','absent') NOT NULL DEFAULT 'journee',
    cout           INT UNSIGNED NOT NULL DEFAULT 0,      -- fige a la saisie (taux_journalier x coef)
    commentaire    VARCHAR(255) NULL,
    cree_par       INT UNSIGNED NULL,
    cree_le        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modifie_le     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_pointage_employe_jour (employe_id, date_pointage),
    INDEX idx_pointages_chantier (chantier_id, date_pointage),
    CONSTRAINT fk_pointages_chantier FOREIGN KEY (chantier_id) REFERENCES chantiers (id) ON DELETE CASCADE,
    CONSTRAINT fk_pointages_lot      FOREIGN KEY (lot_id)      REFERENCES lots (id)      ON DELETE SET NULL,
    CONSTRAINT fk_pointages_employe  FOREIGN KEY (employe_id)  REFERENCES employes (id)  ON DELETE CASCADE,
    CONSTRAINT fk_pointages_auteur   FOREIGN KEY (cree_par)    REFERENCES utilisateurs (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
