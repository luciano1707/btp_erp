-- Statut de validation des paiements (workflow centralise).
ALTER TABLE paiements
    ADD COLUMN statut ENUM('en_attente','valide','refuse') NOT NULL DEFAULT 'valide' AFTER mode,
    ADD INDEX idx_paiements_statut (statut);

UPDATE paiements SET statut = 'valide' WHERE statut <> 'valide';
