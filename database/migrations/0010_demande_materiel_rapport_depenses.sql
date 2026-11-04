-- =========================================================
-- Migration 0010 - Demandes de materiel, Rapports journaliers,
-- Depenses, Budgets, RFI, Qualite, Securite, Incidents, Notifications
-- Aligné sur le CDC Digital Chantier
-- =========================================================

-- Demandes de materiel
CREATE TABLE IF NOT EXISTS demandes_materiel (
    id                INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    numero            VARCHAR(30) NOT NULL UNIQUE,
    chantier_id       INT UNSIGNED NULL,
    demandeur_id      INT UNSIGNED NOT NULL,
    objet             VARCHAR(150) NOT NULL,
    urgence           ENUM('normale','urgente','tres_urgente') NOT NULL DEFAULT 'normale',
    statut            ENUM('brouillon','en_attente','valide','refuse','traite','annule') NOT NULL DEFAULT 'en_attente',
    magasinier_id     INT UNSIGNED NULL,
    date_demande      DATE NOT NULL,
    date_traitement   DATETIME NULL,
    motif_refus       TEXT NULL,
    notes             TEXT NULL,
    cree_le           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modifie_le        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_dm_chantier (chantier_id),
    INDEX idx_dm_demandeur (demandeur_id),
    INDEX idx_dm_statut (statut),
    INDEX idx_dm_date (date_demande),
    CONSTRAINT fk_dm_chantier  FOREIGN KEY (chantier_id)  REFERENCES chantiers (id)      ON DELETE SET NULL,
    CONSTRAINT fk_dm_demandeur FOREIGN KEY (demandeur_id) REFERENCES utilisateurs (id) ON DELETE RESTRICT,
    CONSTRAINT fk_dm_magasinier FOREIGN KEY (magasinier_id) REFERENCES utilisateurs (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS demandes_materiel_lignes (
    id                INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    demande_id        INT UNSIGNED NOT NULL,
    materiau_id       INT UNSIGNED NULL,
    designation       VARCHAR(150) NOT NULL,
    unite             VARCHAR(20)  NOT NULL DEFAULT 'U',
    quantite_demandee DECIMAL(12,3) NOT NULL DEFAULT 0,
    quantite_sortie   DECIMAL(12,3) NOT NULL DEFAULT 0,
    prix_unitaire     DECIMAL(14,2) NOT NULL DEFAULT 0,
    cree_le           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_dml_demande (demande_id),
    INDEX idx_dml_materiau (materiau_id),
    CONSTRAINT fk_dml_demande  FOREIGN KEY (demande_id)  REFERENCES demandes_materiel (id) ON DELETE CASCADE,
    CONSTRAINT fk_dml_materiau FOREIGN KEY (materiau_id) REFERENCES materiaux (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Rapports journaliers
CREATE TABLE IF NOT EXISTS rapports_journaliers (
    id                INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    numero            VARCHAR(30) NOT NULL UNIQUE,
    chantier_id       INT UNSIGNED NOT NULL,
    chef_chantier_id  INT UNSIGNED NOT NULL,
    date_rapport      DATE NOT NULL,
    meteo             VARCHAR(50) NULL,
    travaux_realises  TEXT NULL,
    avancement_pct    TINYINT UNSIGNED NULL,
    problemes         TEXT NULL,
    incidents         TEXT NULL,
    observations      TEXT NULL,
    statut            ENUM('brouillon','soumis','consulte','archive') NOT NULL DEFAULT 'brouillon',
    soumis_le         DATETIME NULL,
    consulte_par      INT UNSIGNED NULL,
    consulte_le       DATETIME NULL,
    cree_le           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modifie_le        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_rj_chantier_date (chantier_id, date_rapport),
    INDEX idx_rj_chef (chef_chantier_id),
    INDEX idx_rj_statut (statut),
    CONSTRAINT fk_rj_chantier FOREIGN KEY (chantier_id)      REFERENCES chantiers (id)      ON DELETE RESTRICT,
    CONSTRAINT fk_rj_chef     FOREIGN KEY (chef_chantier_id) REFERENCES utilisateurs (id) ON DELETE RESTRICT,
    CONSTRAINT fk_rj_consulte FOREIGN KEY (consulte_par)     REFERENCES utilisateurs (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS rapport_journalier_personnel (
    id                INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    rapport_id        INT UNSIGNED NOT NULL,
    employe_id        INT UNSIGNED NULL,
    nom_complet       VARCHAR(150) NOT NULL,
    poste             VARCHAR(100) NULL,
    heures_travail    DECIMAL(5,2) NOT NULL DEFAULT 0,
    heures_sup        DECIMAL(5,2) NOT NULL DEFAULT 0,
    presence          ENUM('present','absent','retard') NOT NULL DEFAULT 'present',
    cree_le           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_rjp_rapport (rapport_id),
    CONSTRAINT fk_rjp_rapport FOREIGN KEY (rapport_id) REFERENCES rapports_journaliers (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS rapport_journalier_materiaux (
    id                INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    rapport_id        INT UNSIGNED NOT NULL,
    materiau_id       INT UNSIGNED NULL,
    designation       VARCHAR(150) NOT NULL,
    unite             VARCHAR(20)  NOT NULL DEFAULT 'U',
    quantite_consommee DECIMAL(12,3) NOT NULL DEFAULT 0,
    cree_le           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_rjm_rapport (rapport_id),
    CONSTRAINT fk_rjm_rapport FOREIGN KEY (rapport_id) REFERENCES rapports_journaliers (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS rapport_journalier_photos (
    id                INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    rapport_id        INT UNSIGNED NOT NULL,
    chemin_fichier    VARCHAR(255) NOT NULL,
    legende           VARCHAR(150) NULL,
    cree_le           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_rjph_rapport (rapport_id),
    CONSTRAINT fk_rjph_rapport FOREIGN KEY (rapport_id) REFERENCES rapports_journaliers (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Depenses
CREATE TABLE IF NOT EXISTS depenses (
    id                INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    numero            VARCHAR(30) NOT NULL UNIQUE,
    chantier_id       INT UNSIGNED NULL,
    declarant_id      INT UNSIGNED NOT NULL,
    categorie         VARCHAR(80) NOT NULL,
    libelle           VARCHAR(150) NOT NULL,
    montant           DECIMAL(14,2) NOT NULL DEFAULT 0,
    devise            VARCHAR(10) NOT NULL DEFAULT 'MGA',
    date_depense      DATE NOT NULL,
    mode_paiement     VARCHAR(30) NULL,
    beneficiaire      VARCHAR(150) NULL,
    justificatif      VARCHAR(255) NULL,
    statut            ENUM('brouillon','en_attente','valide','rejete','comptabilise') NOT NULL DEFAULT 'en_attente',
    valide_par        INT UNSIGNED NULL,
    valide_le         DATETIME NULL,
    motif_rejet       TEXT NULL,
    notes             TEXT NULL,
    cree_le           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modifie_le        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_dep_chantier (chantier_id),
    INDEX idx_dep_declarant (declarant_id),
    INDEX idx_dep_statut (statut),
    INDEX idx_dep_date (date_depense),
    CONSTRAINT fk_dep_chantier  FOREIGN KEY (chantier_id)  REFERENCES chantiers (id)      ON DELETE SET NULL,
    CONSTRAINT fk_dep_declarant FOREIGN KEY (declarant_id) REFERENCES utilisateurs (id) ON DELETE RESTRICT,
    CONSTRAINT fk_dep_valide    FOREIGN KEY (valide_par)   REFERENCES utilisateurs (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Budgets
CREATE TABLE IF NOT EXISTS budgets (
    id                INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    chantier_id       INT UNSIGNED NOT NULL,
    annee             YEAR NOT NULL,
    budget_previsionnel DECIMAL(16,2) NOT NULL DEFAULT 0,
    budget_revision    DECIMAL(16,2) NOT NULL DEFAULT 0,
    devise            VARCHAR(10) NOT NULL DEFAULT 'MGA',
    statut            ENUM('ouvert','cloture') NOT NULL DEFAULT 'ouvert',
    notes             TEXT NULL,
    cree_par          INT UNSIGNED NULL,
    cree_le           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modifie_le        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_budget_chantier_annee (chantier_id, annee),
    INDEX idx_budget_annee (annee),
    CONSTRAINT fk_budget_chantier FOREIGN KEY (chantier_id) REFERENCES chantiers (id)      ON DELETE RESTRICT,
    CONSTRAINT fk_budget_cree     FOREIGN KEY (cree_par)     REFERENCES utilisateurs (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS budget_lignes (
    id                INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    budget_id         INT UNSIGNED NOT NULL,
    rubrique          VARCHAR(80) NOT NULL,
    montant_prevu     DECIMAL(14,2) NOT NULL DEFAULT 0,
    montant_engage    DECIMAL(14,2) NOT NULL DEFAULT 0,
    montant_reel      DECIMAL(14,2) NOT NULL DEFAULT 0,
    cree_le           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_bl_budget (budget_id),
    CONSTRAINT fk_bl_budget FOREIGN KEY (budget_id) REFERENCES budgets (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- RFI
CREATE TABLE IF NOT EXISTS rfi (
    id                INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    numero            VARCHAR(30) NOT NULL UNIQUE,
    chantier_id       INT UNSIGNED NOT NULL,
    emetteur_id       INT UNSIGNED NOT NULL,
    objet             VARCHAR(150) NOT NULL,
    question          TEXT NOT NULL,
    priorite          ENUM('basse','normale','haute','critique') NOT NULL DEFAULT 'normale',
    date_limite       DATE NULL,
    statut            ENUM('ouvert','en_cours','repondu','cloture','annule') NOT NULL DEFAULT 'ouvert',
    reponse           TEXT NULL,
    repondu_par       INT UNSIGNED NULL,
    repondu_le        DATETIME NULL,
    cree_le           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modifie_le        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_rfi_chantier (chantier_id),
    INDEX idx_rfi_emetteur (emetteur_id),
    INDEX idx_rfi_statut (statut),
    CONSTRAINT fk_rfi_chantier FOREIGN KEY (chantier_id) REFERENCES chantiers (id)      ON DELETE RESTRICT,
    CONSTRAINT fk_rfi_emetteur FOREIGN KEY (emetteur_id) REFERENCES utilisateurs (id) ON DELETE RESTRICT,
    CONSTRAINT fk_rfi_repondu  FOREIGN KEY (repondu_par) REFERENCES utilisateurs (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Qualite
CREATE TABLE IF NOT EXISTS qualite_inspections (
    id                INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    numero            VARCHAR(30) NOT NULL UNIQUE,
    chantier_id       INT UNSIGNED NOT NULL,
    inspecteur_id     INT UNSIGNED NOT NULL,
    lot_id            INT UNSIGNED NULL,
    date_inspection   DATE NOT NULL,
    type_inspection   VARCHAR(80) NULL,
    resultat          ENUM('conforme','non_conforme','reserve') NOT NULL DEFAULT 'conforme',
    constat           TEXT NULL,
    action_corrective TEXT NULL,
    statut            ENUM('ouvert','en_cours','clos') NOT NULL DEFAULT 'ouvert',
    cree_le           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modifie_le        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_qi_chantier (chantier_id),
    INDEX idx_qi_inspecteur (inspecteur_id),
    CONSTRAINT fk_qi_chantier   FOREIGN KEY (chantier_id)   REFERENCES chantiers (id)      ON DELETE RESTRICT,
    CONSTRAINT fk_qi_inspecteur FOREIGN KEY (inspecteur_id) REFERENCES utilisateurs (id) ON DELETE RESTRICT,
    CONSTRAINT fk_qi_lot        FOREIGN KEY (lot_id)        REFERENCES lots (id)           ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Securite
CREATE TABLE IF NOT EXISTS securite_observations (
    id                INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    numero            VARCHAR(30) NOT NULL UNIQUE,
    chantier_id       INT UNSIGNED NOT NULL,
    declarant_id      INT UNSIGNED NOT NULL,
    date_observation  DATE NOT NULL,
    lieu              VARCHAR(150) NULL,
    type_observation  ENUM('danger','risque','bonne_pratique','autre') NOT NULL DEFAULT 'danger',
    description       TEXT NOT NULL,
    action_immediate  TEXT NULL,
    mesure_preventive TEXT NULL,
    statut            ENUM('ouvert','en_cours','clos') NOT NULL DEFAULT 'ouvert',
    cree_le           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modifie_le        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_so_chantier (chantier_id),
    INDEX idx_so_declarant (declarant_id),
    CONSTRAINT fk_so_chantier  FOREIGN KEY (chantier_id)  REFERENCES chantiers (id)      ON DELETE RESTRICT,
    CONSTRAINT fk_so_declarant FOREIGN KEY (declarant_id) REFERENCES utilisateurs (id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Incidents
CREATE TABLE IF NOT EXISTS incidents (
    id                INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    numero            VARCHAR(30) NOT NULL UNIQUE,
    chantier_id       INT UNSIGNED NOT NULL,
    declarant_id      INT UNSIGNED NOT NULL,
    date_incident     DATETIME NOT NULL,
    lieu              VARCHAR(150) NULL,
    type_incident     ENUM('incident','accident','presque_accident') NOT NULL DEFAULT 'incident',
    gravite           ENUM('faible','moyenne','grave','critique') NOT NULL DEFAULT 'faible',
    victimes          TEXT NULL,
    description       TEXT NOT NULL,
    premiers_secours  TEXT NULL,
    action_corrective TEXT NULL,
    statut            ENUM('ouvert','enquete','clos') NOT NULL DEFAULT 'ouvert',
    suivi_par         INT UNSIGNED NULL,
    cree_le           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modifie_le        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_inc_chantier (chantier_id),
    INDEX idx_inc_declarant (declarant_id),
    INDEX idx_inc_statut (statut),
    CONSTRAINT fk_inc_chantier  FOREIGN KEY (chantier_id)  REFERENCES chantiers (id)      ON DELETE RESTRICT,
    CONSTRAINT fk_inc_declarant FOREIGN KEY (declarant_id) REFERENCES utilisateurs (id) ON DELETE RESTRICT,
    CONSTRAINT fk_inc_suivi     FOREIGN KEY (suivi_par)    REFERENCES utilisateurs (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Notifications
CREATE TABLE IF NOT EXISTS notifications (
    id                BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    utilisateur_id    INT UNSIGNED NOT NULL,
    type              VARCHAR(50) NOT NULL,
    titre             VARCHAR(150) NOT NULL,
    message           TEXT NOT NULL,
    lien              VARCHAR(150) NULL,
    lu                TINYINT(1) NOT NULL DEFAULT 0,
    lu_le             DATETIME NULL,
    cree_le           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_notif_user (utilisateur_id),
    INDEX idx_notif_lu (lu),
    INDEX idx_notif_cree (cree_le),
    CONSTRAINT fk_notif_user FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
