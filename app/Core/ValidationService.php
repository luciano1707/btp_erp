<?php

namespace App\Core;

use App\Models\Notification;
use App\Models\Parametre;
use PDO;
use RuntimeException;
use Throwable;

/**
 * Service central de validation.
 * Gere le cycle BROUILLON -> EN_ATTENTE -> VALIDE / REFUSE, la double validation
 * configurable et la mise a jour du statut metier de l'operation concernee.
 */
final class ValidationService
{
    /** @var array<string,array<string,mixed>> */
    private const TYPES = [
        'devis' => [
            'module' => 'devis', 'label' => 'Devis', 'table' => 'devis',
            'validateur' => 'directeur', 'auteur' => 'cree_par',
            'champ_montant' => 'montant_ttc', 'champ_chantier' => 'chantier_id',
            'champ_reference' => 'reference',
            'statuts' => ['en_attente' => 'envoye', 'valide' => 'accepte', 'refuse' => 'refuse'],
        ],
        'depense' => [
            'module' => 'depenses', 'label' => 'Depense', 'table' => 'depenses',
            'validateur' => 'comptable', 'auteur' => 'declarant_id',
            'champ_montant' => 'montant', 'champ_chantier' => 'chantier_id',
            'champ_reference' => 'numero',
            'statuts' => ['en_attente' => 'en_attente', 'valide' => 'valide', 'refuse' => 'rejete'],
        ],
        'paiement' => [
            'module' => 'paiements', 'label' => 'Paiement', 'table' => 'paiements',
            'validateur' => 'comptable', 'auteur' => 'cree_par',
            'champ_montant' => 'montant', 'champ_chantier' => null,
            'champ_reference' => 'reference_paiement', 'statuts' => [],
        ],
        'chantier_creation' => [
            'module' => 'chantiers', 'label' => 'Creation de chantier', 'table' => 'chantiers',
            'validateur' => 'directeur', 'auteur' => null,
            'champ_montant' => 'budget_previsionnel', 'champ_chantier' => 'id',
            'champ_reference' => 'code', 'statuts' => [],
        ],
        'chantier_modification' => [
            'module' => 'chantiers', 'label' => 'Modification de chantier', 'table' => 'chantiers',
            'validateur' => 'directeur', 'auteur' => null,
            'champ_montant' => 'budget_previsionnel', 'champ_chantier' => 'id',
            'champ_reference' => 'code', 'statuts' => [],
        ],
        'sortie_stock' => [
            'module' => 'stock', 'label' => 'Sortie exceptionnelle de stock', 'table' => 'mouvements_stock',
            'validateur' => 'directeur', 'auteur' => 'cree_par',
            'champ_montant' => null, 'champ_chantier' => 'chantier_id',
            'champ_reference' => 'motif', 'statuts' => [],
        ],
        'demande_materiel' => [
            'module' => 'demandes_materiel', 'label' => 'Demande de materiel', 'table' => 'demandes_materiel',
            'validateur' => 'directeur', 'auteur' => 'demandeur_id',
            'champ_montant' => null, 'champ_chantier' => 'chantier_id',
            'champ_reference' => 'numero',
            'statuts' => ['en_attente' => 'en_attente', 'valide' => 'valide', 'refuse' => 'refuse'],
        ],
    ];

    /** @return string[] */
    public static function types(): array
    {
        return array_keys(self::TYPES);
    }

    /** @return string[] */
    public static function typesAutorises(?string $role): array
    {
        if ($role === 'directeur') {
            return self::types();
        }
        if ($role === 'comptable') {
            return ['depense', 'paiement'];
        }
        return [];
    }

    public static function libelle(string $type): string
    {
        return (string) (self::TYPES[$type]['label'] ?? $type);
    }

    /** @return array<string,mixed> */
    private function config(string $type): array
    {
        if (!isset(self::TYPES[$type])) {
            throw new RuntimeException('Type d\'operation inconnu : ' . $type);
        }
        return self::TYPES[$type];
    }

    /**
     * Cree ou remet en attente une demande de validation.
     *
     * @param array<string,mixed> $options
     * @return array<string,mixed>
     */
    public function soumettre(array $options): array
    {
        $type = (string) ($options['type_operation'] ?? '');
        $operationId = (int) ($options['operation_id'] ?? 0);
        $soumetteurId = (int) ($options['soumetteur_id'] ?? 0);
        $config = $this->config($type);

        if ($operationId <= 0 || $soumetteurId <= 0) {
            throw new RuntimeException('Operation ou soumetteur invalide.');
        }

        $operation = $this->chargerOperation($type, $operationId);
        if ($operation === null) {
            throw new RuntimeException('Operation introuvable.');
        }

        // Un auteur ne peut pas soumettre une operation dont il n'est pas l'auteur
        // (sauf operation systeme sans colonne auteur).
        $champAuteur = $config['auteur'];
        if (is_string($champAuteur) && isset($operation[$champAuteur])
            && (int) $operation[$champAuteur] !== $soumetteurId) {
            throw new RuntimeException('Vous ne pouvez pas soumettre cette operation.');
        }

        $montant = $this->extraireMontant($config, $operation, $options);
        $chantierId = $this->extraireChantier($type, $config, $operation, $options);
        $reference = $this->extraireReference($config, $operation);
        $etapes = $this->nombreEtapes($type, $montant);

        $pdo = Database::connexion();
        $existante = $this->trouverParOperation($type, $operationId);

        $meta = $options['meta'] ?? [];
        if (!is_array($meta)) {
            $meta = [];
        }
        $meta['libelle'] = $config['label'];
        if (isset($options['justificatif'])) {
            $meta['justificatif'] = $options['justificatif'];
        }

        $donnees = [
            'module' => $config['module'],
            'reference' => $reference,
            'chantier_id' => $chantierId,
            'montant' => $montant,
            'soumetteur_id' => $soumetteurId,
            'statut' => 'en_attente',
            'etape' => 1,
            'etapes_totales' => $etapes,
            'validateur_id' => null,
            'motif_refus' => null,
            'date_soumission' => date('Y-m-d H:i:s'),
            'date_decision' => null,
            'meta' => json_encode($meta, JSON_UNESCAPED_UNICODE),
        ];

        if ($existante !== null) {
            if ($existante['statut'] === 'en_attente') {
                throw new RuntimeException('Cette operation est deja en attente de validation.');
            }
            $sql = 'UPDATE validations SET module = :module, reference = :reference,
                        chantier_id = :chantier_id, montant = :montant, soumetteur_id = :soumetteur_id,
                        statut = :statut, etape = :etape, etapes_totales = :etapes_totales,
                        validateur_id = :valideur_id, motif_refus = :motif_refus,
                        date_soumission = :date_soumission, date_decision = :date_decision, meta = :meta
                    WHERE id = :id';
            $donnees['id'] = (int) $existante['id'];
            $pdo->prepare($sql)->execute($donnees);
            $validationId = (int) $existante['id'];
        } else {
            $sql = 'INSERT INTO validations
                        (type_operation, module, operation_id, reference, chantier_id, montant,
                         soumetteur_id, statut, etape, etapes_totales, validateur_id, motif_refus,
                         date_soumission, date_decision, meta)
                    VALUES
                        (:type_operation, :module, :operation_id, :reference, :chantier_id, :montant,
                         :soumetteur_id, :statut, :etape, :etapes_totales, :valideur_id, :motif_refus,
                         :date_soumission, :date_decision, :meta)';
            $donnees['type_operation'] = $type;
            $donnees['operation_id'] = $operationId;
            $pdo->prepare($sql)->execute($donnees);
            $validationId = (int) $pdo->lastInsertId();
        }

        $this->appliquerStatutMetier($type, $operationId, 'en_attente', $validationId);
        $this->notifierValidateurs($validationId, 1, $etapes, $type, $reference, $montant);

        Audit::enregistrer('validation.soumission', 'validation', $validationId, [
            'type_operation' => $type,
            'operation_id' => $operationId,
            'etapes_totales' => $etapes,
            'montant' => $montant,
        ], $soumetteurId);

        return $this->details($validationId) ?? [];
    }

    /**
     * Enregistre une decision (validation ou refus) sur la demande courante.
     *
     * @return array<string,mixed>
     */
    public function decider(int $validationId, int $utilisateurId, string $role, bool $approuve, ?string $motif = null): array
    {
        $validation = $this->trouver($validationId);
        if ($validation === null) {
            throw new RuntimeException('Demande de validation introuvable.');
        }
        if ($validation['statut'] !== 'en_attente') {
            throw new RuntimeException('Cette demande a deja ete traitee.');
        }
        if ((int) $validation['soumetteur_id'] === $utilisateurId) {
            throw new RuntimeException('L\'auto-validation est interdite.');
        }

        $type = (string) $validation['type_operation'];
        $etape = (int) $validation['etape'];
        $etapesTotales = (int) $validation['etapes_totales'];
        $roleRequis = $this->rolePourEtape($type, $etape, $etapesTotales);

        if ($role !== $roleRequis) {
            throw new RuntimeException('Vous n\'etes pas autorise a valider cette etape.');
        }

        $pdo = Database::connexion();
        $maintenant = date('Y-m-d H:i:s');
        $meta = json_decode((string) ($validation['meta'] ?? '{}'), true);
        if (!is_array($meta)) {
            $meta = [];
        }
        $meta['decisions'][] = [
            'etape' => $etape,
            'utilisateur_id' => $utilisateurId,
            'role' => $role,
            'decision' => $approuve ? 'valide' : 'refuse',
            'motif' => $approuve ? null : $motif,
            'date' => $maintenant,
        ];

        if (!$approuve) {
            $motif = trim((string) $motif);
            if ($motif === '') {
                throw new RuntimeException('Le motif de refus est obligatoire.');
            }
            $pdo->prepare('UPDATE validations
                    SET statut = :statut, validateur_id = :validateur_id, date_decision = :date_decision,
                        motif_refus = :motif, meta = :meta
                    WHERE id = :id AND statut = :ancien')
                ->execute([
                    'statut' => 'refuse', 'validateur_id' => $utilisateurId,
                    'date_decision' => $maintenant, 'motif' => $motif,
                    'meta' => json_encode($meta, JSON_UNESCAPED_UNICODE),
                    'id' => $validationId, 'ancien' => 'en_attente',
                ]);
            $this->appliquerStatutMetier($type, (int) $validation['operation_id'], 'refuse', $validationId, $motif, $utilisateurId);
            $this->notifierSoumetteur($validation, 'refuse', $motif);
            Audit::enregistrer('validation.refus', 'validation', $validationId, [
                'type_operation' => $type, 'operation_id' => (int) $validation['operation_id'],
                'motif' => $motif,
            ], $utilisateurId);
            return $this->details($validationId) ?? [];
        }

        if ($etape < $etapesTotales) {
            $pdo->prepare('UPDATE validations
                    SET etape = :etape, validateur_id = :validateur_id, meta = :meta
                    WHERE id = :id AND statut = :ancien')
                ->execute([
                    'etape' => $etape + 1, 'validateur_id' => $utilisateurId,
                    'meta' => json_encode($meta, JSON_UNESCAPED_UNICODE),
                    'id' => $validationId, 'ancien' => 'en_attente',
                ]);
            $this->notifierValidateurs(
                $validationId, $etape + 1, $etapesTotales, $type,
                (string) ($validation['reference'] ?? ''), $validation['montant'] !== null ? (float) $validation['montant'] : null
            );
            $this->notifierSoumetteur($validation, 'premiere_validation', null);
            Audit::enregistrer('validation.premiere_validation', 'validation', $validationId, [
                'type_operation' => $type, 'operation_id' => (int) $validation['operation_id'],
                'etape' => $etape, 'etapes_totales' => $etapesTotales,
            ], $utilisateurId);
            return $this->details($validationId) ?? [];
        }

        $pdo->prepare('UPDATE validations
                SET statut = :statut, validateur_id = :validateur_id, date_decision = :date_decision,
                    meta = :meta
                WHERE id = :id AND statut = :ancien')
            ->execute([
                'statut' => 'valide', 'validateur_id' => $utilisateurId,
                'date_decision' => $maintenant,
                'meta' => json_encode($meta, JSON_UNESCAPED_UNICODE),
                'id' => $validationId, 'ancien' => 'en_attente',
            ]);
        $this->appliquerStatutMetier($type, (int) $validation['operation_id'], 'valide', $validationId, null, $utilisateurId);
        $this->notifierSoumetteur($validation, 'valide', null);
        Audit::enregistrer('validation.validation', 'validation', $validationId, [
            'type_operation' => $type, 'operation_id' => (int) $validation['operation_id'],
            'etape' => $etape,
        ], $utilisateurId);

        return $this->details($validationId) ?? [];
    }

    /** @return array<string,mixed>|null */
    public function trouver(int $id): ?array
    {
        $stmt = Database::connexion()->prepare('SELECT * FROM validations WHERE id = :id');
        $stmt->execute(['id' => $id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return $row === false ? null : $row;
    }

    /** @return array<string,mixed>|null */
    public function trouverParOperation(string $type, int $operationId): ?array
    {
        $stmt = Database::connexion()->prepare(
            'SELECT * FROM validations WHERE type_operation = :type AND operation_id = :op ORDER BY id DESC LIMIT 1'
        );
        $stmt->execute(['type' => $type, 'op' => $operationId]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return $row === false ? null : $row;
    }

    public function estValidee(string $type, int $operationId): bool
    {
        $row = $this->trouverParOperation($type, $operationId);
        return $row !== null && $row['statut'] === 'valide';
    }

    /**
     * Liste paginee des demandes visibles par un utilisateur.
     * Un validateur ne voit que les types qu'il peut traiter ; un auteur voit
     * toujours ses propres demandes.
     *
     * @param array<string,mixed> $filtres
     * @return array{elements:array<int,array<string,mixed>>,total:int}
     */
    public function lister(array $filtres, ?string $role, ?int $utilisateurId, int $limite = 100, int $decalage = 0): array
    {
        $sql = 'SELECT v.*, c.nom AS chantier_nom, vp.facture_id AS facture_id,
                       u_s.nom AS soumetteur_nom, u_s.prenom AS soumetteur_prenom, u_s.role AS soumetteur_role,
                       u_v.nom AS validateur_nom, u_v.prenom AS validateur_prenom, u_v.role AS validateur_role
                FROM validations v
                LEFT JOIN utilisateurs u_s ON u_s.id = v.soumetteur_id
                LEFT JOIN utilisateurs u_v ON u_v.id = v.validateur_id
                LEFT JOIN chantiers c ON c.id = v.chantier_id
                LEFT JOIN paiements vp ON v.type_operation = \'paiement\' AND vp.id = v.operation_id
                WHERE 1=1';
        $params = [];

        $types = self::typesAutorises($role);
        if ($role !== 'directeur') {
            if ($types !== [] && $utilisateurId !== null) {
                $ph = [];
                foreach ($types as $i => $type) {
                    $ph[] = ':type' . $i;
                    $params['type' . $i] = $type;
                }
                $sql .= ' AND (v.type_operation IN (' . implode(', ', $ph) . ') OR v.soumetteur_id = :utilisateur)';
                $params['utilisateur'] = $utilisateurId;
            } elseif ($utilisateurId !== null) {
                $sql .= ' AND v.soumetteur_id = :utilisateur';
                $params['utilisateur'] = $utilisateurId;
            } else {
                $sql .= ' AND 1=0';
            }
        }

        foreach (['type_operation', 'statut', 'module', 'chantier_id', 'operation_id'] as $champ) {
            if (!empty($filtres[$champ])) {
                $sql .= " AND v.$champ = :$champ";
                $params[$champ] = $filtres[$champ];
            }
        }
        if (!empty($filtres['recherche'])) {
            $sql .= ' AND (v.reference LIKE :recherche OR v.motif_refus LIKE :recherche2)';
            $params['recherche'] = '%' . $filtres['recherche'] . '%';
            $params['recherche2'] = '%' . $filtres['recherche'] . '%';
        }

        $reqTotal = Database::connexion()->prepare(preg_replace('/SELECT v\.\*/', 'SELECT COUNT(*)', $sql, 1));
        $reqTotal->execute($params);
        $total = (int) $reqTotal->fetchColumn();

        $sql .= ' ORDER BY CASE v.statut WHEN \'en_attente\' THEN 0 ELSE 1 END, v.date_soumission DESC, v.id DESC LIMIT :limite OFFSET :decalage';
        $stmt = Database::connexion()->prepare($sql);
        foreach ($params as $cle => $valeur) {
            $stmt->bindValue(':' . $cle, $valeur);
        }
        $stmt->bindValue(':limite', $limite, PDO::PARAM_INT);
        $stmt->bindValue(':decalage', $decalage, PDO::PARAM_INT);
        $stmt->execute();

        $elements = $stmt->fetchAll(PDO::FETCH_ASSOC);
        foreach ($elements as &$element) {
            $element['meta'] = json_decode((string) ($element['meta'] ?? '{}'), true) ?: [];
            $element['libelle_type'] = self::libelle((string) $element['type_operation']);
            $element['role_attendu'] = $this->rolePourEtape(
                (string) $element['type_operation'],
                (int) $element['etape'],
                (int) $element['etapes_totales']
            );
        }
        unset($element);

        return ['elements' => $elements, 'total' => $total];
    }

    /** @return array<string,mixed>|null */
    public function details(int $id): ?array
    {
        $stmt = Database::connexion()->prepare(
            'SELECT v.*,
                    u_s.nom AS soumetteur_nom, u_s.prenom AS soumetteur_prenom, u_s.role AS soumetteur_role,
                    u_v.nom AS validateur_nom, u_v.prenom AS validateur_prenom, u_v.role AS validateur_role
             FROM validations v
             LEFT JOIN utilisateurs u_s ON u_s.id = v.soumetteur_id
             LEFT JOIN utilisateurs u_v ON u_v.id = v.validateur_id
             WHERE v.id = :id'
        );
        $stmt->execute(['id' => $id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($row === false) {
            return null;
        }
        $row['meta'] = json_decode((string) ($row['meta'] ?? '{}'), true) ?: [];
        $row['libelle_type'] = self::libelle((string) $row['type_operation']);
        $row['role_attendu'] = $this->rolePourEtape(
            (string) $row['type_operation'], (int) $row['etape'], (int) $row['etapes_totales']
        );
        $row['operation'] = $this->chargerOperation((string) $row['type_operation'], (int) $row['operation_id']);
        return $row;
    }

    /** @return array{en_attente:int,valide:int,refuse:int,brouillon:int} */
    public function indicateurs(?string $role = null): array
    {
        $types = self::typesAutorises($role);
        if ($types === []) {
            return ['en_attente' => 0, 'valide' => 0, 'refuse' => 0, 'brouillon' => 0];
        }
        $placeholders = implode(', ', array_fill(0, count($types), '?'));
        $stmt = Database::connexion()->prepare(
            "SELECT statut, COUNT(*) AS nombre FROM validations
             WHERE type_operation IN ($placeholders) GROUP BY statut"
        );
        $stmt->execute($types);
        $resultat = ['en_attente' => 0, 'valide' => 0, 'refuse' => 0, 'brouillon' => 0];
        foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
            $resultat[$row['statut']] = (int) $row['nombre'];
        }
        return $resultat;
    }

    /** @return array<string,mixed>|null */
    public function chargerOperation(string $type, int $operationId): ?array
    {
        $config = $this->config($type);
        $table = (string) $config['table'];

        if ($type === 'paiement') {
            $stmt = Database::connexion()->prepare(
                'SELECT p.*, f.reference AS facture_reference, f.client_nom, f.chantier_id,
                        c.nom AS chantier_nom
                 FROM paiements p
                 JOIN factures f ON f.id = p.facture_id
                 LEFT JOIN chantiers c ON c.id = f.chantier_id
                 WHERE p.id = :id'
            );
        } elseif ($type === 'depense') {
            $stmt = Database::connexion()->prepare(
                "SELECT d.*, c.nom AS chantier_nom,
                        TRIM(CONCAT(COALESCE(u.prenom, ''), ' ', COALESCE(u.nom, ''))) AS declarant_nom
                 FROM depenses d
                 LEFT JOIN chantiers c ON c.id = d.chantier_id
                 LEFT JOIN utilisateurs u ON u.id = d.declarant_id
                 WHERE d.id = :id"
            );
        } elseif ($type === 'devis') {
            $stmt = Database::connexion()->prepare(
                'SELECT d.*, c.nom AS client_nom, ch.nom AS chantier_nom
                 FROM devis d
                 LEFT JOIN clients c ON c.id = d.client_id
                 LEFT JOIN chantiers ch ON ch.id = d.chantier_id
                 WHERE d.id = :id'
            );
        } elseif ($type === 'sortie_stock') {
            $stmt = Database::connexion()->prepare(
                'SELECT m.*, mat.designation AS materiau_designation, mat.code AS materiau_code,
                        c.nom AS chantier_nom
                 FROM mouvements_stock m
                 LEFT JOIN materiaux mat ON mat.id = m.materiau_id
                 LEFT JOIN chantiers c ON c.id = m.chantier_id
                 WHERE m.id = :id'
            );
        } elseif ($type === 'demande_materiel') {
            $stmt = Database::connexion()->prepare(
                'SELECT dm.*, c.nom AS chantier_nom
                 FROM demandes_materiel dm
                 LEFT JOIN chantiers c ON c.id = dm.chantier_id
                 WHERE dm.id = :id'
            );
        } else {
            $stmt = Database::connexion()->prepare("SELECT * FROM $table WHERE id = :id");
        }

        $stmt->execute(['id' => $operationId]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($row !== false && $type === 'demande_materiel') {
            $lignes = Database::connexion()->prepare(
                'SELECT designation, unite, quantite_demandee
                 FROM demandes_materiel_lignes WHERE demande_id = :id ORDER BY id ASC'
            );
            $lignes->execute(['id' => $operationId]);
            $row['lignes'] = $lignes->fetchAll(PDO::FETCH_ASSOC);
        }
        return $row === false ? null : $row;
    }

    private function nombreEtapes(string $type, ?float $montant): int
    {
        if ($type !== 'depense') {
            return 1;
        }
        $seuil = (float) ((new Parametre())->obtenir('seuil_double_validation', '0') ?? '0');
        if ($seuil > 0 && $montant !== null && $montant >= $seuil) {
            return 2;
        }
        return 1;
    }

    private function rolePourEtape(string $type, int $etape, int $etapesTotales): string
    {
        $config = $this->config($type);
        if ($etapesTotales > 1) {
            return $etape >= 2 ? 'directeur' : (string) $config['validateur'];
        }
        return (string) $config['validateur'];
    }

    /** @param array<string,mixed> $config @param array<string,mixed> $operation */
    private function extraireMontant(array $config, array $operation, array $options): ?float
    {
        if (isset($options['montant']) && $options['montant'] !== '') {
            return (float) $options['montant'];
        }
        $champ = $config['champ_montant'];
        if (is_string($champ) && isset($operation[$champ])) {
            return (float) $operation[$champ];
        }
        return null;
    }

    /** @param array<string,mixed> $config @param array<string,mixed> $operation */
    private function extraireChantier(string $type, array $config, array $operation, array $options): ?int
    {
        if (isset($options['chantier_id']) && $options['chantier_id'] !== '') {
            return (int) $options['chantier_id'];
        }
        if ($type === 'paiement') {
            return isset($operation['chantier_id']) ? (int) $operation['chantier_id'] : null;
        }
        $champ = $config['champ_chantier'];
        if (is_string($champ) && isset($operation[$champ]) && $operation[$champ] !== null) {
            return (int) $operation[$champ];
        }
        return null;
    }

    /** @param array<string,mixed> $config @param array<string,mixed> $operation */
    private function extraireReference(array $config, array $operation): ?string
    {
        $champ = $config['champ_reference'];
        if (is_string($champ) && isset($operation[$champ]) && $operation[$champ] !== '') {
            return mb_substr((string) $operation[$champ], 0, 80);
        }
        return null;
    }

    private function appliquerStatutMetier(
        string $type,
        int $operationId,
        string $etat,
        int $validationId,
        ?string $motif = null,
        ?int $validateurId = null
    ): void {
        $config = $this->config($type);
        $pdo = Database::connexion();
        $maintenant = date('Y-m-d H:i:s');

        if ($type === 'chantier_modification') {
            if ($etat === 'valide') {
                $validation = $this->trouver($validationId);
                $meta = json_decode((string) ($validation['meta'] ?? '{}'), true) ?: [];
                $changements = $meta['changements'] ?? [];
                if (is_array($changements) && $changements !== []) {
                    $autorises = ['nom', 'type', 'client_id', 'responsable_id', 'localisation',
                        'date_debut', 'date_fin_prevue', 'date_fin_reelle', 'budget_previsionnel',
                        'statut', 'description', 'actif', 'code'];
                    $champs = [];
                    $params = ['id' => $operationId];
                    foreach ($autorises as $champ) {
                        if (array_key_exists($champ, $changements)) {
                            $champs[] = "$champ = :$champ";
                            $params[$champ] = $changements[$champ];
                        }
                    }
                    if ($champs !== []) {
                        $pdo->prepare('UPDATE chantiers SET ' . implode(', ', $champs) . ' WHERE id = :id')->execute($params);
                    }
                }
            }
            return;
        }

        if ($type === 'paiement') {
            if (!in_array($etat, ['valide', 'refuse'], true)) {
                return;
            }
            $paiement = $this->chargerOperation($type, $operationId);
            if ($paiement !== null) {
                Database::connexion()->prepare('UPDATE paiements SET statut = :statut WHERE id = :id')
                    ->execute(['statut' => $etat, 'id' => $operationId]);
                if (isset($paiement['facture_id'])) {
                    (new \App\Models\Facture())->recalculerPaiements((int) $paiement['facture_id']);
                }
            }
            return;
        }

        if ($type === 'sortie_stock') {
            if (in_array($etat, ['en_attente', 'valide', 'refuse'], true)) {
                $pdo = Database::connexion();
                $pdo->prepare('UPDATE mouvements_stock SET statut = :statut WHERE id = :id')
                    ->execute(['statut' => $etat === 'valide' ? 'valide' : ($etat === 'refuse' ? 'refuse' : 'en_attente'), 'id' => $operationId]);
            }
            return;
        }

        $statuts = $config['statuts'];
        if (!is_array($statuts) || !isset($statuts[$etat])) {
            return;
        }

        $nouveau = $statuts[$etat];
        if ($type === 'demande_materiel') {
            $pdo->prepare(
                'UPDATE demandes_materiel
                 SET statut = :statut, motif_refus = :motif, date_traitement = :date_traitement
                 WHERE id = :id'
            )->execute([
                'statut' => $nouveau,
                'motif' => $etat === 'refuse' ? $motif : null,
                'date_traitement' => $etat === 'en_attente' ? null : $maintenant,
                'id' => $operationId,
            ]);
            return;
        }
        if ($type === 'depense') {
            $params = ['statut' => $nouveau, 'id' => $operationId];
            $sql = 'UPDATE depenses SET statut = :statut';
            if ($etat === 'valide') {
                $sql .= ', valide_par = :validateur, valide_le = :date';
                $params['validateur'] = $validateurId;
                $params['date'] = $maintenant;
            } elseif ($etat === 'refuse') {
                $sql .= ', motif_rejet = :motif, valide_le = :date';
                $params['motif'] = $motif;
                $params['date'] = $maintenant;
            }
            $sql .= ' WHERE id = :id';
            $pdo->prepare($sql)->execute($params);
            return;
        }

        $pdo->prepare('UPDATE ' . $config['table'] . ' SET statut = :statut WHERE id = :id')
            ->execute(['statut' => $nouveau, 'id' => $operationId]);
    }

    private function notifierValidateurs(
        int $validationId,
        int $etape,
        int $etapesTotales,
        string $type,
        string $reference,
        ?float $montant
    ): void {
        $role = $this->rolePourEtape($type, $etape, $etapesTotales);
        $libelle = self::libelle($type);
        $titre = $etape > 1 ? 'Validation finale requise' : 'Nouvelle demande de validation';
        $message = $libelle . ' ' . $reference;
        if ($montant !== null) {
            $message .= ' - ' . number_format($montant, 0, ',', ' ') . ' Ar';
        }
        $validation = $this->trouver($validationId);
        $exclure = $validation !== null ? (int) $validation['soumetteur_id'] : 0;
        $lien = $validation !== null
            ? $this->lienOperation($type, (int) $validation['operation_id'])
            : '/';
        Notification::pourRolesSauf([$role], $exclure, 'validation', $titre, $message, $lien);
    }

    /** @param array<string,mixed> $validation */
    private function notifierSoumetteur(array $validation, string $etat, ?string $motif): void
    {
        $titre = match ($etat) {
            'valide' => 'Operation validee',
            'refuse' => 'Operation refusee',
            default => 'Premiere validation enregistree',
        };
        $message = self::libelle((string) $validation['type_operation']) . ' ' . ($validation['reference'] ?? '');
        if ($motif !== null && $motif !== '') {
            $message .= ' : ' . $motif;
        }
        $lien = $this->lienOperation(
            (string) $validation['type_operation'],
            (int) $validation['operation_id']
        );
        Notification::creer((int) $validation['soumetteur_id'], 'validation', $titre, $message, $lien);
    }

    private function lienOperation(string $type, int $operationId): string
    {
        return match ($type) {
            'devis' => '/devis/' . $operationId,
            'depense' => '/depenses/' . $operationId,
            'paiement' => $this->lienFacturePaiement($operationId),
            'chantier_creation', 'chantier_modification' => '/chantiers/' . $operationId,
            'demande_materiel' => '/demandes-materiel/' . $operationId,
            'sortie_stock' => '/stock',
            default => '/',
        };
    }

    private function lienFacturePaiement(int $paiementId): string
    {
        $paiement = $this->chargerOperation('paiement', $paiementId);
        return $paiement !== null && isset($paiement['facture_id'])
            ? '/factures/' . (int) $paiement['facture_id']
            : '/factures';
    }
}
