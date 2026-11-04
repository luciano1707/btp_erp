-- Migration 0011 : Table des validations centralisées
-- Ce système permet de tracker toutes les opérations nécessitant une approbation

CREATE TABLE IF NOT EXISTS validations (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    type_operation VARCHAR(50) NOT NULL COMMENT 'Type de l\'opération (devis, depense, chantier, etc.)',
    operation_id BIGINT UNSIGNED NOT NULL COMMENT 'ID de l\'opération concernée',
    soumetteur_id INT UNSIGNED NOT NULL COMMENT 'ID de l\'utilisateur qui soumet',
    validateur_id INT UNSIGNED NULL COMMENT 'ID du validateur',
    statut ENUM('brouillon', 'en_attente', 'valide', 'refuse') NOT NULL DEFAULT 'brouillon',
    motif_refus TEXT NULL COMMENT 'Motif du refus',
    date_soumission DATETIME NULL COMMENT 'Date de soumission pour validation',
    date_decision DATETIME NULL COMMENT 'Date de la décision (validation/refus)',
    meta JSON NULL COMMENT 'Données supplémentaires (filtres, seuils, etc.)',
    cree_le TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modifie_le TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_type_operation (type_operation),
    INDEX idx_operation (type_operation, operation_id),
    INDEX idx_statut (statut),
    INDEX idx_soumetteur (soumetteur_id),
    INDEX idx_validateur (validateur_id),
    INDEX idx_date_soumission (date_soumission),
    CONSTRAINT fk_valid_soumetteur FOREIGN KEY (soumetteur_id) REFERENCES utilisateurs (id) ON DELETE RESTRICT,
    CONSTRAINT fk_valid_validateur FOREIGN KEY (validateur_id) REFERENCES utilisateurs (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Validations centralisées des opérations';
