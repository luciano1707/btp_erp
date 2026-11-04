-- Migration 0012 : workflow de validation centralise (etapes, module, montant)
-- Complete la table validations creee en 0011 sans casser les donnees existantes.

ALTER TABLE validations
    ADD COLUMN module VARCHAR(50) NULL AFTER type_operation,
    ADD COLUMN reference VARCHAR(80) NULL AFTER operation_id,
    ADD COLUMN chantier_id INT UNSIGNED NULL AFTER reference,
    ADD COLUMN montant DECIMAL(16,2) NULL AFTER chantier_id,
    ADD COLUMN etape TINYINT UNSIGNED NOT NULL DEFAULT 1 AFTER statut,
    ADD COLUMN etapes_totales TINYINT UNSIGNED NOT NULL DEFAULT 1 AFTER etape,
    ADD INDEX idx_valid_chantier (chantier_id),
    ADD INDEX idx_valid_module (module);

ALTER TABLE validations
    ADD CONSTRAINT fk_valid_chantier FOREIGN KEY (chantier_id) REFERENCES chantiers (id) ON DELETE SET NULL;

CREATE INDEX idx_valid_operation_unique ON validations (type_operation, operation_id);

-- Seuil de double validation des depenses (0 = desactive). Configurable dans parametres.
INSERT INTO parametres (cle, valeur, description)
VALUES ('seuil_double_validation', '0', 'Montant a partir duquel une depense exige une double validation (comptable puis directeur). 0 = desactive')
ON DUPLICATE KEY UPDATE cle = cle;

INSERT INTO parametres (cle, valeur, description)
VALUES ('conditions_paiement_devis', 'Paiement a 30 jours date de facture', 'Conditions de paiement affichees sur les devis approuves')
ON DUPLICATE KEY UPDATE cle = cle;
