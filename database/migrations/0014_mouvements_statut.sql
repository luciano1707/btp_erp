-- Statut de validation des mouvements de stock exceptionnels.
ALTER TABLE mouvements_stock
    ADD COLUMN statut ENUM('en_attente','valide','refuse') NOT NULL DEFAULT 'valide' AFTER motif,
    ADD INDEX idx_mouvements_statut (statut);

UPDATE mouvements_stock SET statut = 'valide' WHERE statut <> 'valide';
