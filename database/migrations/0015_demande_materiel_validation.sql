-- Les demandes de materiel deja en attente rejoignent le workflow central.
INSERT INTO validations (
    type_operation, module, operation_id, reference, chantier_id, montant,
    soumetteur_id, statut, etape, etapes_totales, date_soumission, meta
)
SELECT
    'demande_materiel', 'demandes_materiel', dm.id, dm.numero, dm.chantier_id, NULL,
    dm.demandeur_id, 'en_attente', 1, 1, COALESCE(dm.cree_le, NOW()),
    JSON_OBJECT('libelle', 'Demande de materiel')
FROM demandes_materiel dm
WHERE dm.statut = 'en_attente'
  AND NOT EXISTS (
      SELECT 1
      FROM validations v
      WHERE v.type_operation = 'demande_materiel'
        AND v.operation_id = dm.id
  );
