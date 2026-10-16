-- =========================================================
--  Migration 0003 - Referentiels de base (Phase 2)
--  Employes, Clients, Fournisseurs, Engins, Materiaux.
--  Montants en Ariary (entiers, sans centimes). SQL portable MariaDB/MySQL 8.
-- =========================================================

-- Employes / main d'oeuvre
CREATE TABLE IF NOT EXISTS employes (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    matricule       VARCHAR(30) NULL UNIQUE,
    nom             VARCHAR(100) NOT NULL,
    prenom          VARCHAR(100) NULL,
    telephone       VARCHAR(30) NULL,
    poste           VARCHAR(100) NULL,               -- ex: macon, chauffeur, chef d'equipe
    type_contrat    ENUM('journalier','mensuel','sous_traitant') NOT NULL DEFAULT 'journalier',
    taux_journalier INT UNSIGNED NULL,               -- cout par jour, en Ariary
    actif           TINYINT(1) NOT NULL DEFAULT 1,
    cree_le         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modifie_le      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_employes_nom (nom),
    INDEX idx_employes_actif (actif)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Clients
CREATE TABLE IF NOT EXISTS clients (
    id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nom        VARCHAR(150) NOT NULL,                -- raison sociale ou nom
    contact    VARCHAR(100) NULL,                    -- personne a contacter
    telephone  VARCHAR(30) NULL,
    email      VARCHAR(190) NULL,
    adresse    VARCHAR(255) NULL,
    nif        VARCHAR(30) NULL,                     -- numero fiscal (Madagascar)
    stat       VARCHAR(30) NULL,                     -- numero statistique (Madagascar)
    actif      TINYINT(1) NOT NULL DEFAULT 1,
    cree_le    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modifie_le TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_clients_nom (nom),
    INDEX idx_clients_actif (actif)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Fournisseurs
CREATE TABLE IF NOT EXISTS fournisseurs (
    id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nom        VARCHAR(150) NOT NULL,
    contact    VARCHAR(100) NULL,
    telephone  VARCHAR(30) NULL,
    email      VARCHAR(190) NULL,
    adresse    VARCHAR(255) NULL,
    categorie  VARCHAR(100) NULL,                    -- ex: materiaux, carburant, location engins
    nif        VARCHAR(30) NULL,
    stat       VARCHAR(30) NULL,
    actif      TINYINT(1) NOT NULL DEFAULT 1,
    cree_le    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modifie_le TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_fournisseurs_nom (nom),
    INDEX idx_fournisseurs_actif (actif)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Engins / materiel roulant
CREATE TABLE IF NOT EXISTS engins (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code            VARCHAR(30) NULL UNIQUE,
    designation     VARCHAR(150) NOT NULL,           -- ex: Pelle hydraulique CAT 320
    type            VARCHAR(80) NULL,                -- ex: camion, pelle, betonniere
    immatriculation VARCHAR(30) NULL,
    etat            ENUM('disponible','en_service','maintenance','hors_service') NOT NULL DEFAULT 'disponible',
    cout_horaire    INT UNSIGNED NULL,               -- cout d'utilisation par heure, en Ariary
    actif           TINYINT(1) NOT NULL DEFAULT 1,
    cree_le         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modifie_le      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_engins_designation (designation),
    INDEX idx_engins_etat (etat)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Materiaux (catalogue ; la gestion de stock viendra en Phase 5)
CREATE TABLE IF NOT EXISTS materiaux (
    id             INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code           VARCHAR(30) NULL UNIQUE,
    designation    VARCHAR(150) NOT NULL,            -- ex: Ciment CEM II 42.5
    unite          VARCHAR(20) NOT NULL DEFAULT 'unite', -- ex: sac, m3, kg, tonne, unite
    prix_unitaire  INT UNSIGNED NULL,                -- prix de reference, en Ariary
    seuil_alerte   INT UNSIGNED NULL,                -- seuil de reapprovisionnement (stock)
    actif          TINYINT(1) NOT NULL DEFAULT 1,
    cree_le        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modifie_le     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_materiaux_designation (designation),
    INDEX idx_materiaux_actif (actif)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
