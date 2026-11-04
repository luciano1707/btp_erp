import 'package:flutter/material.dart';

enum FieldType {
  text,
  number,
  date,
  email,
  phone,
  textarea,
  select,
  remoteSelect,
  checkbox,
}

enum ModuleLineMode { document, materiel, budget }

class ModuleField {
  const ModuleField(
    this.name,
    this.label, {
    this.type = FieldType.text,
    this.required = false,
    this.options = const {},
    this.remoteSource,
    this.remoteLabel = 'nom',
  });

  final String name;
  final String label;
  final FieldType type;
  final bool required;
  final Map<String, String> options;
  final String? remoteSource;
  final String remoteLabel;
}

class AppModule {
  const AppModule({
    required this.id,
    required this.title,
    required this.endpoint,
    required this.icon,
    required this.permission,
    required this.readRoles,
    this.writeRoles = const [],
    this.createRoles,
    this.deleteRoles = const [],
    this.editFieldsByRole = const {},
    this.createFieldsByRole = const {},
    this.fields = const [],
    this.hasLines = false,
    this.workflow,
    this.workflowRoles = const [],
    this.lineMode = ModuleLineMode.document,
    this.deletable = false,
    this.updatable = true,
    this.searchable = true,
    this.filterFields = const {},
    this.printPath,
  });

  final String id;
  final String title;
  final String endpoint;
  final IconData icon;
  final String permission;
  final List<String> readRoles;
  final List<String> writeRoles;
  final List<String>? createRoles;
  final List<String> deleteRoles;
  final Map<String, List<String>> editFieldsByRole;
  final Map<String, List<String>> createFieldsByRole;
  final List<ModuleField> fields;
  final bool hasLines;
  final String? workflow;
  final List<String> workflowRoles;
  final ModuleLineMode lineMode;
  final bool deletable;

  /// L'API expose-t-il une route PUT sur `{endpoint}/{id}` ?
  /// Le stock et le journal n'en ont pas : leurs lignes sont derivées ou immuables.
  final bool updatable;

  /// L'API accepte-t-elle le parametre `recherche` sur la liste ?
  final bool searchable;

  /// Filtresserver-side : nom du parametre -> libelle (journal : action / entite).
  final Map<String, String> filterFields;

  /// Route d'impression : suffixe ajoute a l'id (ex: `/factures/{id}/imprimer`).
  final String? printPath;

  bool canRead(String role) => role == 'directeur' || readRoles.contains(role);
  bool canWrite(String role) =>
      role == 'directeur' || writeRoles.contains(role);
  bool canCreate(String role) =>
      role == 'directeur' || (createRoles ?? writeRoles).contains(role);
  bool canDelete(String role) =>
      role == 'directeur' || deleteRoles.contains(role);
  bool canWorkflow(String role) =>
      role == 'directeur' || workflowRoles.contains(role);

  List<ModuleField> fieldsFor(String role, {bool editing = false}) {
    if (role == 'directeur' && !editing) return fields;
    final allowed = (editing ? editFieldsByRole : createFieldsByRole)[role];
    if (allowed == null) return fields;
    return fields.where((field) => allowed.contains(field.name)).toList();
  }

  bool canEdit(String role) =>
      role == 'directeur' ||
      writeRoles.contains(role) && (editFieldsByRole[role]?.isNotEmpty ?? true);
}

const referentialModules = <AppModule>[
  AppModule(
    id: 'employes',
    title: 'Employés',
    endpoint: 'employes',
    icon: Icons.badge_outlined,
    permission: 'referentiels',
    readRoles: ['chef_chantier', 'comptable', 'magasinier'],
    fields: [
      ModuleField('matricule', 'Matricule'),
      ModuleField('nom', 'Nom', required: true),
      ModuleField('prenom', 'Prénom'),
      ModuleField('telephone', 'Téléphone', type: FieldType.phone),
      ModuleField('poste', 'Poste'),
      ModuleField(
        'type_contrat',
        'Type de contrat',
        type: FieldType.select,
        options: {
          'journalier': 'Journalier',
          'mensuel': 'Mensuel',
          'sous_traitant': 'Sous-traitant',
        },
      ),
      ModuleField(
        'taux_journalier',
        'Taux journalier (Ar)',
        type: FieldType.number,
      ),
      ModuleField('actif', 'Actif', type: FieldType.checkbox),
    ],
    deletable: true,
  ),
  AppModule(
    id: 'clients',
    title: 'Clients',
    endpoint: 'clients',
    icon: Icons.people_outline,
    permission: 'referentiels',
    readRoles: ['chef_chantier', 'comptable', 'magasinier'],
    writeRoles: ['comptable'],
    createRoles: [],
    editFieldsByRole: {
      'comptable': ['contact', 'telephone', 'email', 'adresse', 'nif', 'stat'],
    },
    fields: [
      ModuleField('nom', 'Nom / raison sociale', required: true),
      ModuleField('contact', 'Contact'),
      ModuleField('telephone', 'Téléphone', type: FieldType.phone),
      ModuleField('email', 'E-mail', type: FieldType.email),
      ModuleField('adresse', 'Adresse', type: FieldType.textarea),
      ModuleField('nif', 'NIF'),
      ModuleField('stat', 'STAT'),
      ModuleField('actif', 'Actif', type: FieldType.checkbox),
    ],
    deletable: true,
  ),
  AppModule(
    id: 'fournisseurs',
    title: 'Fournisseurs',
    endpoint: 'fournisseurs',
    icon: Icons.local_shipping_outlined,
    permission: 'referentiels',
    readRoles: ['chef_chantier', 'comptable', 'magasinier'],
    writeRoles: ['comptable', 'magasinier'],
    createRoles: ['magasinier'],
    createFieldsByRole: {
      'magasinier': [
        'nom',
        'categorie',
        'contact',
        'telephone',
        'email',
        'adresse',
        'actif',
      ],
    },
    editFieldsByRole: {
      'comptable': ['contact', 'telephone', 'email', 'adresse', 'nif', 'stat'],
      'magasinier': [
        'nom',
        'categorie',
        'contact',
        'telephone',
        'email',
        'adresse',
        'actif',
      ],
    },
    fields: [
      ModuleField('nom', 'Nom', required: true),
      ModuleField('categorie', 'Catégorie'),
      ModuleField('contact', 'Contact'),
      ModuleField('telephone', 'Téléphone', type: FieldType.phone),
      ModuleField('email', 'E-mail', type: FieldType.email),
      ModuleField('adresse', 'Adresse', type: FieldType.textarea),
      ModuleField('nif', 'NIF'),
      ModuleField('stat', 'STAT'),
      ModuleField('actif', 'Actif', type: FieldType.checkbox),
    ],
    deletable: true,
  ),
  AppModule(
    id: 'engins',
    title: 'Engins',
    endpoint: 'engins',
    icon: Icons.precision_manufacturing_outlined,
    permission: 'referentiels',
    readRoles: ['chef_chantier', 'comptable', 'magasinier'],
    writeRoles: ['chef_chantier', 'magasinier'],
    createRoles: [],
    editFieldsByRole: {
      'chef_chantier': ['etat'],
      'magasinier': ['etat', 'actif'],
    },
    fields: [
      ModuleField('code', 'Code'),
      ModuleField('designation', 'Désignation', required: true),
      ModuleField('type', 'Type'),
      ModuleField('immatriculation', 'Immatriculation'),
      ModuleField(
        'etat',
        'État',
        type: FieldType.select,
        options: {
          'disponible': 'Disponible',
          'en_service': 'En service',
          'maintenance': 'Maintenance',
          'hors_service': 'Hors service',
        },
      ),
      ModuleField('cout_horaire', 'Coût horaire (Ar)', type: FieldType.number),
      ModuleField('actif', 'Actif', type: FieldType.checkbox),
    ],
    deletable: true,
  ),
  AppModule(
    id: 'materiaux',
    title: 'Matériaux',
    endpoint: 'materiaux',
    icon: Icons.category_outlined,
    permission: 'referentiels',
    readRoles: ['chef_chantier', 'comptable', 'magasinier'],
    writeRoles: ['magasinier'],
    createRoles: ['magasinier'],
    deleteRoles: ['magasinier'],
    createFieldsByRole: {
      'magasinier': [
        'code',
        'designation',
        'unite',
        'prix_unitaire',
        'seuil_alerte',
        'actif',
      ],
    },
    editFieldsByRole: {
      'magasinier': [
        'code',
        'designation',
        'unite',
        'prix_unitaire',
        'seuil_alerte',
        'actif',
      ],
    },
    fields: [
      ModuleField('code', 'Code'),
      ModuleField('designation', 'Désignation', required: true),
      ModuleField('unite', 'Unité'),
      ModuleField(
        'prix_unitaire',
        'Prix unitaire (Ar)',
        type: FieldType.number,
      ),
      ModuleField('seuil_alerte', 'Seuil d’alerte', type: FieldType.number),
      ModuleField('actif', 'Actif', type: FieldType.checkbox),
    ],
    deletable: true,
  ),
];

const appModules = <AppModule>[
  AppModule(
    id: 'chantiers',
    title: 'Chantiers',
    endpoint: 'chantiers',
    icon: Icons.construction_outlined,
    permission: 'chantiers',
    readRoles: ['chef_chantier', 'comptable', 'magasinier'],
    writeRoles: ['chef_chantier'],
    editFieldsByRole: {
      'chef_chantier': [
        'responsable_id',
        'localisation',
        'date_fin_reelle',
        'statut',
        'description',
      ],
    },
    createRoles: [],
    fields: [
      ModuleField('code', 'Code'),
      ModuleField('nom', 'Nom du chantier', required: true),
      ModuleField(
        'type',
        'Type',
        type: FieldType.select,
        options: {'batiment': 'Bâtiment', 'route': 'Route', 'autre': 'Autre'},
      ),
      ModuleField(
        'client_id',
        'Client',
        type: FieldType.remoteSelect,
        remoteSource: 'clients',
        required: true,
      ),
      ModuleField(
        'responsable_id',
        'Responsable',
        type: FieldType.remoteSelect,
        remoteSource: 'utilisateurs',
        remoteLabel: 'display_name',
      ),
      ModuleField('localisation', 'Localisation'),
      ModuleField('date_debut', 'Date de début', type: FieldType.date),
      ModuleField('date_fin_prevue', 'Fin prévue', type: FieldType.date),
      ModuleField('date_fin_reelle', 'Fin réelle', type: FieldType.date),
      ModuleField(
        'budget_previsionnel',
        'Budget prévisionnel (Ar)',
        type: FieldType.number,
      ),
      ModuleField(
        'statut',
        'Statut',
        type: FieldType.select,
        options: {
          'planifie': 'Planifié',
          'en_cours': 'En cours',
          'suspendu': 'Suspendu',
          'termine': 'Terminé',
          'annule': 'Annulé',
        },
      ),
      ModuleField('description', 'Description', type: FieldType.textarea),
    ],
    workflow: 'chantier',
    deletable: true,
  ),
  AppModule(
    id: 'achats',
    title: 'Achats',
    endpoint: 'achats',
    icon: Icons.shopping_cart_outlined,
    permission: 'achats',
    readRoles: ['chef_chantier', 'comptable', 'magasinier'],
    writeRoles: ['comptable', 'magasinier'],
    fields: [
      ModuleField('reference', 'Référence'),
      ModuleField(
        'fournisseur_id',
        'Fournisseur',
        type: FieldType.remoteSelect,
        remoteSource: 'fournisseurs',
        required: true,
      ),
      ModuleField(
        'chantier_id',
        'Chantier',
        type: FieldType.remoteSelect,
        remoteSource: 'chantiers',
      ),
      ModuleField(
        'date_achat',
        'Date d’achat',
        type: FieldType.date,
        required: true,
      ),
      ModuleField('notes', 'Notes', type: FieldType.textarea),
    ],
    hasLines: true,
    workflow: 'achat',
    deletable: true,
  ),
  AppModule(
    id: 'stock',
    title: 'Stock',
    endpoint: 'stock',
    icon: Icons.inventory_2_outlined,
    permission: 'stock',
    readRoles: ['chef_chantier', 'comptable', 'magasinier'],
    writeRoles: ['magasinier'],
    fields: [
      ModuleField(
        'materiau_id',
        'Matériau',
        type: FieldType.remoteSelect,
        remoteSource: 'materiaux',
        remoteLabel: 'designation',
        required: true,
      ),
      ModuleField(
        'type',
        'Mouvement',
        type: FieldType.select,
        options: {
          'entree': 'Entrée',
          'sortie': 'Sortie',
          'ajustement': 'Ajustement',
        },
      ),
      ModuleField(
        'quantite',
        'Quantité',
        type: FieldType.number,
        required: true,
      ),
      ModuleField(
        'chantier_id',
        'Chantier (facultatif)',
        type: FieldType.remoteSelect,
        remoteSource: 'chantiers',
      ),
      ModuleField('motif', 'Motif'),
      ModuleField('date_mouvement', 'Date', type: FieldType.date),
    ],
    workflow: 'stock',
    // Le stock est un etat derive des mouvements : pas de PUT /stock/{id} dans l'API.
    updatable: false,
    searchable: false,
  ),
  AppModule(
    id: 'devis',
    title: 'Devis',
    endpoint: 'devis',
    icon: Icons.request_quote_outlined,
    permission: 'devis',
    readRoles: ['chef_chantier', 'comptable'],
    writeRoles: ['comptable'],
    fields: [
      ModuleField('reference', 'Référence'),
      ModuleField(
        'client_id',
        'Client',
        type: FieldType.remoteSelect,
        remoteSource: 'clients',
        required: true,
      ),
      ModuleField(
        'chantier_id',
        'Chantier',
        type: FieldType.remoteSelect,
        remoteSource: 'chantiers',
      ),
      ModuleField(
        'date_devis',
        'Date du devis',
        type: FieldType.date,
        required: true,
      ),
      ModuleField('validite', 'Validité (jours)', type: FieldType.number),
      ModuleField('notes', 'Notes', type: FieldType.textarea),
    ],
    hasLines: true,
    workflow: 'devis',
    workflowRoles: ['comptable'],
    deletable: true,
    printPath: '/imprimer',
  ),
  AppModule(
    id: 'factures',
    title: 'Factures',
    endpoint: 'factures',
    icon: Icons.receipt_long_outlined,
    permission: 'factures',
    readRoles: ['comptable'],
    writeRoles: ['comptable'],
    fields: [
      ModuleField('reference', 'Référence'),
      ModuleField(
        'client_id',
        'Client',
        type: FieldType.remoteSelect,
        remoteSource: 'clients',
        required: true,
      ),
      ModuleField(
        'chantier_id',
        'Chantier',
        type: FieldType.remoteSelect,
        remoteSource: 'chantiers',
      ),
      ModuleField(
        'date_facture',
        'Date de facture',
        type: FieldType.date,
        required: true,
      ),
      ModuleField('echeance', 'Échéance', type: FieldType.date),
      ModuleField('notes', 'Notes', type: FieldType.textarea),
    ],
    hasLines: true,
    workflow: 'facture',
    workflowRoles: ['comptable'],
    deletable: true,
    printPath: '/imprimer',
  ),
  AppModule(
    id: 'journal',
    title: 'Journal d’audit',
    endpoint: 'journal',
    icon: Icons.history_outlined,
    permission: 'journal',
    readRoles: ['chef_chantier', 'comptable', 'magasinier'],
    deletable: false,
    updatable: false,
    filterFields: {'action': 'Action', 'entite': 'Entité'},
  ),
  AppModule(
    id: 'demandes-materiel',
    title: 'Demandes de matériel',
    endpoint: 'demandes-materiel',
    icon: Icons.playlist_add_check_outlined,
    permission: 'demandes_materiel',
    readRoles: ['chef_chantier', 'comptable', 'magasinier'],
    createRoles: ['chef_chantier'],
    workflowRoles: ['magasinier'],
    fields: [
      ModuleField(
        'chantier_id',
        'Chantier',
        type: FieldType.remoteSelect,
        remoteSource: 'chantiers',
      ),
      ModuleField('objet', 'Objet', required: true),
      ModuleField(
        'urgence',
        'Urgence',
        type: FieldType.select,
        options: {
          'basse': 'Basse',
          'normale': 'Normale',
          'haute': 'Haute',
          'urgente': 'Urgente',
        },
      ),
      ModuleField('date_demande', 'Date', type: FieldType.date, required: true),
      ModuleField('notes', 'Notes', type: FieldType.textarea),
    ],
    hasLines: true,
    lineMode: ModuleLineMode.materiel,
    workflow: 'demande_materiel',
    updatable: false,
  ),
  AppModule(
    id: 'rapports-journaliers',
    title: 'Rapports journaliers',
    endpoint: 'rapports-journaliers',
    icon: Icons.assignment_outlined,
    permission: 'rapports_journaliers',
    readRoles: ['chef_chantier', 'comptable', 'magasinier'],
    writeRoles: ['chef_chantier'],
    workflowRoles: ['chef_chantier'],
    editFieldsByRole: {
      'chef_chantier': [
        'meteo',
        'travaux_realises',
        'avancement_pct',
        'problemes',
        'incidents',
        'observations',
      ],
      'directeur': [
        'date_rapport',
        'meteo',
        'travaux_realises',
        'avancement_pct',
        'problemes',
        'incidents',
        'observations',
      ],
    },
    fields: [
      ModuleField(
        'chantier_id',
        'Chantier',
        type: FieldType.remoteSelect,
        remoteSource: 'chantiers',
        required: true,
      ),
      ModuleField('date_rapport', 'Date', type: FieldType.date, required: true),
      ModuleField('meteo', 'Météo'),
      ModuleField(
        'travaux_realises',
        'Travaux réalisés',
        type: FieldType.textarea,
      ),
      ModuleField('avancement_pct', 'Avancement (%)', type: FieldType.number),
      ModuleField('problemes', 'Problèmes', type: FieldType.textarea),
      ModuleField('incidents', 'Incidents', type: FieldType.textarea),
      ModuleField('observations', 'Observations', type: FieldType.textarea),
    ],
    workflow: 'rapport',
  ),
  AppModule(
    id: 'depenses',
    title: 'Dépenses',
    endpoint: 'depenses',
    icon: Icons.payments_outlined,
    permission: 'depenses',
    readRoles: ['chef_chantier', 'comptable', 'magasinier'],
    createRoles: ['chef_chantier', 'comptable'],
    workflowRoles: ['chef_chantier', 'comptable'],
    fields: [
      ModuleField(
        'chantier_id',
        'Chantier',
        type: FieldType.remoteSelect,
        remoteSource: 'chantiers',
      ),
      ModuleField('categorie', 'Catégorie', required: true),
      ModuleField('libelle', 'Libellé', required: true),
      ModuleField(
        'montant',
        'Montant (Ar)',
        type: FieldType.number,
        required: true,
      ),
      ModuleField('date_depense', 'Date', type: FieldType.date, required: true),
      ModuleField('mode_paiement', 'Mode de paiement'),
      ModuleField('beneficiaire', 'Bénéficiaire'),
      ModuleField('notes', 'Notes', type: FieldType.textarea),
    ],
    workflow: 'depense',
    updatable: false,
  ),
  AppModule(
    id: 'budgets',
    title: 'Budgets',
    endpoint: 'budgets',
    icon: Icons.account_balance_wallet_outlined,
    permission: 'budgets',
    readRoles: ['chef_chantier', 'comptable'],
    writeRoles: ['comptable'],
    editFieldsByRole: {
      'directeur': [
        'budget_previsionnel',
        'budget_revision',
        'statut',
        'notes',
      ],
      'comptable': [
        'budget_previsionnel',
        'budget_revision',
        'statut',
        'notes',
      ],
    },
    fields: [
      ModuleField(
        'chantier_id',
        'Chantier',
        type: FieldType.remoteSelect,
        remoteSource: 'chantiers',
        required: true,
      ),
      ModuleField('annee', 'Année', type: FieldType.number, required: true),
      ModuleField(
        'budget_previsionnel',
        'Budget prévisionnel (Ar)',
        type: FieldType.number,
      ),
      ModuleField('budget_revision', 'Révision (Ar)', type: FieldType.number),
      ModuleField(
        'statut',
        'Statut',
        type: FieldType.select,
        options: {'ouvert': 'Ouvert', 'cloture': 'Clôturé'},
      ),
      ModuleField('notes', 'Notes', type: FieldType.textarea),
    ],
    hasLines: true,
    lineMode: ModuleLineMode.budget,
  ),
  AppModule(
    id: 'rfi',
    title: 'Demandes d’information (RFI)',
    endpoint: 'rfi',
    icon: Icons.question_answer_outlined,
    permission: 'rfi',
    readRoles: ['chef_chantier', 'comptable'],
    createRoles: ['chef_chantier'],
    workflowRoles: ['chef_chantier'],
    fields: [
      ModuleField(
        'chantier_id',
        'Chantier',
        type: FieldType.remoteSelect,
        remoteSource: 'chantiers',
        required: true,
      ),
      ModuleField('objet', 'Objet', required: true),
      ModuleField(
        'question',
        'Question',
        type: FieldType.textarea,
        required: true,
      ),
      ModuleField(
        'priorite',
        'Priorité',
        type: FieldType.select,
        options: {
          'basse': 'Basse',
          'normale': 'Normale',
          'haute': 'Haute',
          'critique': 'Critique',
        },
      ),
      ModuleField('date_limite', 'Date limite', type: FieldType.date),
    ],
    workflow: 'rfi',
    updatable: false,
  ),
  AppModule(
    id: 'qualite',
    title: 'Qualité',
    endpoint: 'qualite',
    icon: Icons.verified_outlined,
    permission: 'qualite',
    readRoles: ['chef_chantier', 'comptable'],
    writeRoles: ['chef_chantier'],
    editFieldsByRole: {
      'chef_chantier': [
        'lot_id',
        'type_inspection',
        'resultat',
        'constat',
        'action_corrective',
        'statut',
      ],
      'directeur': [
        'lot_id',
        'type_inspection',
        'resultat',
        'constat',
        'action_corrective',
        'statut',
      ],
    },
    fields: [
      ModuleField(
        'chantier_id',
        'Chantier',
        type: FieldType.remoteSelect,
        remoteSource: 'chantiers',
        required: true,
      ),
      ModuleField(
        'date_inspection',
        'Date d’inspection',
        type: FieldType.date,
        required: true,
      ),
      ModuleField('type_inspection', 'Type d’inspection'),
      ModuleField(
        'resultat',
        'Résultat',
        type: FieldType.select,
        options: {
          'conforme': 'Conforme',
          'non_conforme': 'Non conforme',
          'reserve': 'Avec réserve',
        },
      ),
      ModuleField('constat', 'Constat', type: FieldType.textarea),
      ModuleField(
        'action_corrective',
        'Action corrective',
        type: FieldType.textarea,
      ),
      ModuleField(
        'statut',
        'Statut',
        type: FieldType.select,
        options: {'ouvert': 'Ouvert', 'en_cours': 'En cours', 'clos': 'Clos'},
      ),
    ],
  ),
  AppModule(
    id: 'securite',
    title: 'Sécurité',
    endpoint: 'securite',
    icon: Icons.health_and_safety_outlined,
    permission: 'securite',
    readRoles: ['chef_chantier', 'comptable'],
    writeRoles: ['chef_chantier'],
    editFieldsByRole: {
      'chef_chantier': [
        'lieu',
        'type_observation',
        'description',
        'action_immediate',
        'mesure_preventive',
        'statut',
      ],
      'directeur': [
        'lieu',
        'type_observation',
        'description',
        'action_immediate',
        'mesure_preventive',
        'statut',
      ],
    },
    fields: [
      ModuleField(
        'chantier_id',
        'Chantier',
        type: FieldType.remoteSelect,
        remoteSource: 'chantiers',
        required: true,
      ),
      ModuleField(
        'date_observation',
        'Date',
        type: FieldType.date,
        required: true,
      ),
      ModuleField('lieu', 'Lieu'),
      ModuleField(
        'type_observation',
        'Type',
        type: FieldType.select,
        options: {
          'danger': 'Danger',
          'risque': 'Risque',
          'bonne_pratique': 'Bonne pratique',
          'autre': 'Autre',
        },
      ),
      ModuleField(
        'description',
        'Description',
        type: FieldType.textarea,
        required: true,
      ),
      ModuleField(
        'action_immediate',
        'Action immédiate',
        type: FieldType.textarea,
      ),
      ModuleField(
        'mesure_preventive',
        'Mesure préventive',
        type: FieldType.textarea,
      ),
      ModuleField(
        'statut',
        'Statut',
        type: FieldType.select,
        options: {'ouvert': 'Ouvert', 'en_cours': 'En cours', 'clos': 'Clos'},
      ),
    ],
  ),
  AppModule(
    id: 'incidents',
    title: 'Incidents',
    endpoint: 'incidents',
    icon: Icons.warning_amber_outlined,
    permission: 'incidents',
    readRoles: ['chef_chantier', 'comptable'],
    writeRoles: ['chef_chantier'],
    editFieldsByRole: {
      'chef_chantier': [
        'lieu',
        'type_incident',
        'gravite',
        'victimes',
        'description',
        'premiers_secours',
        'action_corrective',
        'statut',
      ],
      'directeur': [
        'lieu',
        'type_incident',
        'gravite',
        'victimes',
        'description',
        'premiers_secours',
        'action_corrective',
        'statut',
        'suivi_par',
      ],
    },
    fields: [
      ModuleField(
        'chantier_id',
        'Chantier',
        type: FieldType.remoteSelect,
        remoteSource: 'chantiers',
        required: true,
      ),
      ModuleField(
        'date_incident',
        'Date et heure',
        type: FieldType.text,
        required: true,
      ),
      ModuleField('lieu', 'Lieu'),
      ModuleField(
        'type_incident',
        'Type',
        type: FieldType.select,
        options: {
          'incident': 'Incident',
          'accident': 'Accident',
          'presque_accident': 'Presque-accident',
        },
      ),
      ModuleField(
        'gravite',
        'Gravité',
        type: FieldType.select,
        options: {
          'faible': 'Faible',
          'moyenne': 'Moyenne',
          'grave': 'Grave',
          'critique': 'Critique',
        },
      ),
      ModuleField('victimes', 'Victimes'),
      ModuleField(
        'description',
        'Description',
        type: FieldType.textarea,
        required: true,
      ),
      ModuleField(
        'premiers_secours',
        'Premiers secours',
        type: FieldType.textarea,
      ),
      ModuleField(
        'action_corrective',
        'Action corrective',
        type: FieldType.textarea,
      ),
      ModuleField(
        'statut',
        'Statut',
        type: FieldType.select,
        options: {'ouvert': 'Ouvert', 'en_cours': 'En cours', 'clos': 'Clos'},
      ),
    ],
  ),
];
