import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../chantiers/pointage_screen.dart';
import '../../shared/app_theme.dart';
import '../../shared/labels.dart';
import '../../shared/widgets.dart';
import 'module_catalog.dart';

class ApiModuleScreen extends StatefulWidget {
  const ApiModuleScreen({
    required this.api,
    required this.module,
    required this.role,
    super.key,
  });

  final ApiClient api;
  final AppModule module;
  final String role;

  @override
  State<ApiModuleScreen> createState() => _ApiModuleScreenState();
}

class _ApiModuleScreenState extends State<ApiModuleScreen> {
  final _search = TextEditingController();
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String? _error;
  Timer? _searchDebounce;
  int _loadGeneration = 0;

  List<Map<String, dynamic>> get _visibleItems {
    final query = _normalizeSearch(_search.text.trim());
    if (query.isEmpty || widget.module.searchable) return _items;
    return _items.where((item) {
      final values = [
        ...item.entries.expand(
          (entry) => [entry.key, ..._searchableValues(entry.value)],
        ),
        labelStatut(item['statut']),
        _urgenceLabel(item['urgence']),
        _formatRecordDate(item['date_demande']),
      ];
      return _normalizeSearch(values.join(' ')).contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _load({String? searchOverride}) async {
    _searchDebounce?.cancel();
    final generation = ++_loadGeneration;
    final query = (searchOverride ?? _search.text).trim();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final suffix = !widget.module.searchable || query.isEmpty
          ? ''
          : '?recherche=${Uri.encodeQueryComponent(query)}';
      final response = await widget.api.getData(
        '${widget.module.endpoint}$suffix',
      );
      final records = response is List
          ? response
          : (response as Map)['elements'] as List? ?? [];
      if (!mounted || generation != _loadGeneration) return;
      _items = List<Map<String, dynamic>>.from(records);
    } catch (error) {
      if (generation == _loadGeneration) _error = error.toString();
    } finally {
      if (mounted && generation == _loadGeneration) {
        setState(() => _loading = false);
      }
    }
  }

  void _onSearchChanged(String value) {
    if (!widget.module.searchable) {
      setState(() {});
      return;
    }
    _loadGeneration++;
    setState(() {
      _loading = true;
      _error = null;
    });
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 300),
      () => _load(searchOverride: value),
    );
  }

  Future<void> _searchNow() async {
    if (widget.module.searchable) {
      _searchDebounce?.cancel();
      await _load();
    } else if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.module.title)),
    floatingActionButton:
        widget.module.canCreate(widget.role) && widget.module.fields.isNotEmpty
        ? FloatingActionButton.extended(
            onPressed: () => _edit(),
            icon: const Icon(Icons.add),
            label: const Text('Créer'),
          )
        : null,
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: TextField(
            controller: _search,
            textInputAction: TextInputAction.search,
            onChanged: _onSearchChanged,
            onSubmitted: (_) => _searchNow(),
            decoration: InputDecoration(
              labelText: 'Rechercher',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                onPressed: _searchNow,
                icon: const Icon(Icons.arrow_forward),
              ),
            ),
          ),
        ),
        if (_loading && _items.isNotEmpty)
          const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: _loading && _items.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _error != null && _items.isEmpty
              ? ErrorPanel(message: _error!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: _visibleItems.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.sizeOf(context).height * .28,
                            ),
                            Center(
                              child: Text(
                                _search.text.trim().isNotEmpty &&
                                        widget.module.searchable
                                    ? 'Aucun résultat pour cette recherche.'
                                    : _items.isEmpty
                                    ? 'Aucun élément.'
                                    : 'Aucun résultat pour cette recherche.',
                              ),
                            ),
                          ],
                        )
                      : widget.module.id == 'demandes-materiel'
                      ? _DemandesMaterielTable(
                          items: _visibleItems,
                          onOpen: _open,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                          itemCount: _visibleItems.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) => _ModuleRecordTile(
                            item: _visibleItems[index],
                            module: widget.module,
                            onTap: () => _open(_visibleItems[index]),
                            onEdit: _canEditRecord
                                ? () => _edit(_visibleItems[index])
                                : null,
                            onDelete: _canDeleteRecord
                                ? () => _deleteRecord(_visibleItems[index])
                                : null,
                          ),
                        ),
                ),
        ),
      ],
    ),
  );

  Future<void> _edit([Map<String, dynamic>? item]) async {
    var initial = item;
    if (item != null &&
        widget.module.hasLines &&
        item['lignes'] is! List &&
        item['id'] != null) {
      try {
        initial = Map<String, dynamic>.from(
          await widget.api.getData('${widget.module.endpoint}/${item['id']}')
              as Map,
        );
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error.toString())));
        }
        return;
      }
    }
    if (!mounted) return;
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => ModuleFormScreen(
          api: widget.api,
          module: widget.module,
          role: widget.role,
          initial: initial,
        ),
      ),
    );
    if (saved == true) _load();
  }

  Future<void> _open(Map<String, dynamic> item) async {
    final id = item['id'];
    if (id == null) return;
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => RecordDetailScreen(
          api: widget.api,
          module: widget.module,
          role: widget.role,
          item: item,
        ),
      ),
    );
    if (changed == true) _load();
  }

  /// L'API n'expose pas de modification des documents en cours (workflow) :
  /// on les gere depuis la fiche detail.
  bool get _canEditRecord =>
      widget.module.canEdit(widget.role) &&
      widget.module.updatable &&
      widget.module.fields.isNotEmpty &&
      widget.module.workflow != 'achat' &&
      widget.module.workflow != 'devis' &&
      widget.module.workflow != 'facture';

  bool get _canDeleteRecord =>
      widget.module.canDelete(widget.role) && widget.module.deletable;

  Future<void> _deleteRecord(Map<String, dynamic> item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cet élément ?'),
        content: const Text('Cette action ne peut pas être annulée.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await widget.api.delete('${widget.module.endpoint}/${item['id']}');
      if (mounted) _load();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }
}

class _DemandesMaterielTable extends StatelessWidget {
  const _DemandesMaterielTable({required this.items, required this.onOpen});

  final List<Map<String, dynamic>> items;
  final ValueChanged<Map<String, dynamic>> onOpen;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
    children: [
      Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 18, 16, 10),
              child: Text(
                'Liste des demandes de matériel',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStatePropertyAll(
                  Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                headingRowHeight: 48,
                dataRowMinHeight: 64,
                dataRowMaxHeight: 88,
                columnSpacing: 20,
                horizontalMargin: 16,
                columns: const [
                  DataColumn(label: Text('N°')),
                  DataColumn(label: Text('Objet')),
                  DataColumn(label: Text('Chantier')),
                  DataColumn(label: Text('Demandeur')),
                  DataColumn(label: Text('Urgence')),
                  DataColumn(label: Text('Statut')),
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: [
                  for (final item in items)
                    DataRow(
                      cells: [
                        DataCell(
                          _TableValue(item['numero'] ?? item['id'], width: 120),
                          onTap: () => onOpen(item),
                        ),
                        DataCell(
                          _TableValue(
                            item['objet'],
                            width: 145,
                            emphasized: true,
                          ),
                          onTap: () => onOpen(item),
                        ),
                        DataCell(
                          _TableValue(item['chantier_nom'], width: 150),
                          onTap: () => onOpen(item),
                        ),
                        DataCell(
                          _TableValue(
                            [item['demandeur_prenom'], item['demandeur_nom']]
                                .where(
                                  (value) =>
                                      value != null &&
                                      value.toString().trim().isNotEmpty,
                                )
                                .join(' '),
                            width: 135,
                          ),
                          onTap: () => onOpen(item),
                        ),
                        DataCell(
                          _TableValue(
                            _urgenceLabel(item['urgence']),
                            width: 95,
                          ),
                          onTap: () => onOpen(item),
                        ),
                        DataCell(
                          _StatutPuce(statut: item['statut']?.toString() ?? ''),
                          onTap: () => onOpen(item),
                        ),
                        DataCell(
                          _TableValue(
                            _formatRecordDate(item['date_demande']),
                            width: 100,
                          ),
                          onTap: () => onOpen(item),
                        ),
                        DataCell(
                          TextButton(
                            onPressed: () => onOpen(item),
                            child: const Text('Détail'),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _TableValue extends StatelessWidget {
  const _TableValue(this.value, {required this.width, this.emphasized = false});

  final dynamic value;
  final double width;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: Text(
      value?.toString().trim().isNotEmpty == true ? value.toString() : '—',
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontWeight: emphasized ? FontWeight.w700 : FontWeight.normal,
      ),
    ),
  );
}

String _urgenceLabel(dynamic value) => switch (value?.toString()) {
  'normale' => 'Normale',
  'urgente' => 'Urgente',
  'tres_urgente' => 'Très urgente',
  'basse' => 'Basse',
  final other when other != null && other.isNotEmpty => _readableRecordValue(
    other,
  ),
  _ => '—',
};

Iterable<String> _searchableValues(dynamic value) sync* {
  if (value is Map) {
    for (final entry in value.entries) {
      yield entry.key.toString();
      yield* _searchableValues(entry.value);
    }
  } else if (value is Iterable) {
    for (final item in value) {
      yield* _searchableValues(item);
    }
  } else if (value != null) {
    yield value.toString();
  }
}

String _normalizeSearch(String value) {
  final normalized = StringBuffer();
  for (final rune in value.toLowerCase().runes) {
    normalized.write(switch (rune) {
      0x00e0 || 0x00e1 || 0x00e2 || 0x00e3 || 0x00e4 || 0x00e5 => 'a',
      0x00e8 || 0x00e9 || 0x00ea || 0x00eb => 'e',
      0x00ec || 0x00ed || 0x00ee || 0x00ef => 'i',
      0x00f2 || 0x00f3 || 0x00f4 || 0x00f5 || 0x00f6 => 'o',
      0x00f9 || 0x00fa || 0x00fb || 0x00fc => 'u',
      0x00e7 => 'c',
      0x0153 => 'oe',
      _ => String.fromCharCode(rune),
    });
  }
  return normalized.toString();
}

class _ModuleRecordTile extends StatelessWidget {
  const _ModuleRecordTile({
    required this.item,
    required this.module,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final Map<String, dynamic> item;
  final AppModule module;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final title = _moduleRecordTitle(module, item);
    final subtitle = _moduleRecordSubtitle(module, item, title);
    final statut = item['statut']?.toString();
    final hasActions = onEdit != null || onDelete != null;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.lime,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(module.icon, color: AppColors.forest, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                    if (statut != null && statut.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _StatutPuce(statut: statut),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 4),
              if (hasActions)
                PopupMenuButton<String>(
                  tooltip: 'Actions',
                  icon: const Icon(Icons.more_vert),
                  onSelected: (action) {
                    if (action == 'edit') onEdit?.call();
                    if (action == 'delete') onDelete?.call();
                  },
                  itemBuilder: (_) => [
                    if (onEdit != null)
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 20),
                            SizedBox(width: 10),
                            Text('Modifier'),
                          ],
                        ),
                      ),
                    if (onDelete != null)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Color(0xFF9C422B),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Supprimer',
                              style: TextStyle(color: Color(0xFF9C422B)),
                            ),
                          ],
                        ),
                      ),
                  ],
                )
              else
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(Icons.chevron_right),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String _moduleRecordTitle(AppModule module, Map<String, dynamic> item) {
  String first(List<String> keys) => _firstRecordValue(item, keys);
  final employeeName = [
    item['prenom']?.toString().trim(),
    item['nom']?.toString().trim(),
  ].where((value) => value != null && value.isNotEmpty).join(' ');

  final title = switch (module.id) {
    'employes' =>
      first(['display_name', 'nom_complet']).isNotEmpty
          ? first(['display_name', 'nom_complet'])
          : employeeName.isNotEmpty
          ? employeeName
          : first(['matricule', 'nom']),
    'chantiers' => first(['nom', 'code']),
    'achats' ||
    'devis' ||
    'factures' => first(['reference', 'numero', 'client_nom']),
    'stock' || 'materiaux' || 'engins' => first(['designation', 'nom', 'code']),
    'demandes-materiel' || 'rfi' => first(['objet', 'question', 'numero']),
    'rapports-journaliers' => _joinRecordValues([
      item['chantier_nom'],
      _formatRecordDate(item['date_rapport']),
    ]),
    'depenses' => first(['libelle', 'numero', 'categorie']),
    'budgets' => _joinRecordValues([item['chantier_nom'], item['annee']]),
    'qualite' => first([
      'type_inspection',
      'lot_nom',
      'chantier_nom',
      'numero',
    ]),
    'securite' => _joinRecordValues([
      _readableRecordValue(item['type_observation']),
      item['lieu'],
    ]),
    'incidents' => _joinRecordValues([
      _readableRecordValue(item['type_incident']),
      item['lieu'],
    ]),
    'validations' => _joinRecordValues([
      _readableRecordValue(item['type_operation']),
      item['operation_id'] == null ? null : '#${item['operation_id']}',
    ]),
    'journal' => _joinRecordValues([
      _readableRecordValue(item['action']),
      _readableRecordValue(item['entite']),
    ]),
    _ => first([
      'display_name',
      'nom_complet',
      'nom',
      'designation',
      'reference',
      'numero',
      'objet',
      'libelle',
      'titre',
      'code',
      'chantier_nom',
    ]),
  };

  if (title.isNotEmpty) return title;
  final id = item['id']?.toString();
  if (id == null || id.isEmpty) return module.title;
  return switch (module.id) {
    'demandes-materiel' => 'Demande de matériel #$id',
    'rapports-journaliers' => 'Rapport journalier #$id',
    'depenses' => 'Dépense #$id',
    'budgets' => 'Budget #$id',
    'rfi' => 'Demande d’information #$id',
    'qualite' => 'Inspection qualité #$id',
    'securite' => 'Observation sécurité #$id',
    'incidents' => 'Incident #$id',
    'validations' => 'Approbation #$id',
    _ => 'Enregistrement #$id',
  };
}

String _moduleRecordSubtitle(
  AppModule module,
  Map<String, dynamic> item,
  String title,
) {
  final values = switch (module.id) {
    'employes' => [item['matricule'], item['poste']],
    'chantiers' => [item['code'], item['localisation'], item['client_nom']],
    'achats' => [
      item['fournisseur_nom'],
      item['chantier_nom'],
      _formatRecordDate(item['date_achat']),
    ],
    'devis' => [
      item['client_nom'],
      item['chantier_nom'],
      _formatRecordDate(item['date_devis']),
    ],
    'factures' => [
      item['client_nom'],
      item['chantier_nom'],
      _formatRecordDate(item['date_facture']),
    ],
    'demandes-materiel' => [
      item['numero'],
      item['chantier_nom'],
      _readableRecordValue(item['urgence']),
      _formatRecordDate(item['date_demande']),
    ],
    'rapports-journaliers' => [
      _formatRecordDate(item['date_rapport']),
      item['chef_nom'],
      item['avancement_pct'] == null ? null : '${item['avancement_pct']} %',
    ],
    'depenses' => [
      item['numero'],
      item['chantier_nom'],
      _readableRecordValue(item['categorie']),
      _formatRecordDate(item['date_depense']),
    ],
    'budgets' => [item['code'], 'Année ${item['annee'] ?? ''}'],
    'rfi' => [
      item['numero'],
      item['chantier_nom'],
      _readableRecordValue(item['priorite']),
      _formatRecordDate(item['date_limite']),
    ],
    'qualite' => [
      item['chantier_nom'],
      item['lot_nom'],
      _formatRecordDate(item['date_inspection']),
    ],
    'securite' => [
      item['chantier_nom'],
      _formatRecordDate(item['date_observation']),
      item['declarant_nom'],
    ],
    'incidents' => [
      item['chantier_nom'],
      _formatRecordDate(item['date_incident']),
      _readableRecordValue(item['gravite']),
      item['declarant_nom'],
    ],
    'validations' => [
      item['numero'],
      item['soumetteur_nom'],
      _formatRecordDate(item['date_soumission']),
    ],
    'journal' => [item['description'], _formatRecordDate(item['cree_le'])],
    _ => [
      item['localisation'],
      item['client_nom'],
      item['fournisseur_nom'],
      _formatRecordDate(item['date_achat']),
      _formatRecordDate(item['date_facture']),
    ],
  };
  return _joinRecordValues(
    values.where((value) {
      final text = value?.toString().trim() ?? '';
      return text.isNotEmpty && text != title;
    }),
  );
}

String _firstRecordValue(Map<String, dynamic> item, List<String> keys) {
  for (final key in keys) {
    final value = item[key]?.toString().trim() ?? '';
    if (value.isNotEmpty) return value;
  }
  return '';
}

String _joinRecordValues(Iterable<dynamic> values) => values
    .map((value) => value?.toString().trim() ?? '')
    .where((value) => value.isNotEmpty)
    .join(' · ');

String _formatRecordDate(dynamic value) {
  final date = value?.toString().trim() ?? '';
  return date.isEmpty ? '' : formatDate(date);
}

String _readableRecordValue(dynamic value) {
  final text = value?.toString().trim().replaceAll('_', ' ') ?? '';
  if (text.isEmpty) return '';
  return '${text[0].toUpperCase()}${text.substring(1)}';
}

class _StatutPuce extends StatelessWidget {
  const _StatutPuce({required this.statut});

  final String statut;

  @override
  Widget build(BuildContext context) {
    final couleur = Color(couleurStatut(statut));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        labelStatut(statut),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: couleur,
        ),
      ),
    );
  }
}

class ModuleFormScreen extends StatefulWidget {
  const ModuleFormScreen({
    required this.api,
    required this.module,
    required this.role,
    this.initial,
    super.key,
  });

  final ApiClient api;
  final AppModule module;
  final String role;
  final Map<String, dynamic>? initial;

  @override
  State<ModuleFormScreen> createState() => _ModuleFormScreenState();
}

class _ModuleFormScreenState extends State<ModuleFormScreen> {
  final _form = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, Future<List<Map<String, dynamic>>>> _remoteOptions = {};
  final List<Map<String, TextEditingController>> _lines = [];
  bool _saving = false;

  bool get _editing => widget.initial != null;
  List<ModuleField> get _fields =>
      widget.module.fieldsFor(widget.role, editing: _editing);

  @override
  void initState() {
    super.initState();
    for (final field in _fields) {
      _controllers[field.name] = TextEditingController(
        text: widget.initial?[field.name]?.toString() ?? '',
      );
      if (field.type == FieldType.remoteSelect && field.remoteSource != null) {
        _remoteOptions[field.name] = _loadOptions(field.remoteSource!);
      }
    }
    if (widget.module.lineMode == ModuleLineMode.materiel) {
      _remoteOptions['materiau_id'] = _loadOptions('materiaux');
    }
    if (widget.module.hasLines) {
      final existingLines = widget.initial?['lignes'];
      if (existingLines is List && existingLines.isNotEmpty) {
        for (final item in existingLines.whereType<Map>()) {
          _addLine();
          final row = _lines.last;
          final values = switch (widget.module.lineMode) {
            ModuleLineMode.document => {
              'designation': item['designation'],
              'quantite': item['quantite'],
              'prix_unitaire': item['prix_unitaire'],
            },
            ModuleLineMode.materiel => {
              'materiau_id': item['materiau_id'],
              'designation': item['designation'],
              'quantite_demandee': item['quantite_demandee'],
              'unite': item['unite'],
            },
            ModuleLineMode.budget => {
              'rubrique': item['rubrique'],
              'montant_prevu': item['montant_prevu'],
            },
          };
          for (final entry in values.entries) {
            row[entry.key]!.text = entry.value?.toString() ?? '';
          }
        }
      } else {
        _addLine();
      }
    }
  }

  void _addLine() {
    final controllers = switch (widget.module.lineMode) {
      ModuleLineMode.document => {
        'designation': TextEditingController(),
        'quantite': TextEditingController(text: '1'),
        'prix_unitaire': TextEditingController(),
      },
      ModuleLineMode.materiel => {
        'materiau_id': TextEditingController(),
        'designation': TextEditingController(),
        'quantite_demandee': TextEditingController(text: '1'),
        'unite': TextEditingController(text: 'U'),
      },
      ModuleLineMode.budget => {
        'rubrique': TextEditingController(),
        'montant_prevu': TextEditingController(),
      },
    };
    _lines.add(controllers);
  }

  Future<List<Map<String, dynamic>>> _loadOptions(String endpoint) async {
    final response = await widget.api.getData('$endpoint?limite=200');
    final rows = response is List
        ? response
        : (response as Map)['elements'] as List? ?? [];
    return List<Map<String, dynamic>>.from(rows);
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final row in _lines) {
      for (final controller in row.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        _editing
            ? 'Modifier ${widget.module.title.toLowerCase()}'
            : 'Nouveau ${widget.module.title.toLowerCase()}',
      ),
    ),
    body: Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ..._fields.map(_fieldWidget),
          if (widget.module.hasLines) ...[
            const SizedBox(height: 12),
            const Text(
              'Lignes',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            ..._lines.asMap().entries.map(
              (entry) => _lineWidget(entry.key, entry.value),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => setState(_addLine),
                icon: const Icon(Icons.add),
                label: const Text('Ajouter une ligne'),
              ),
            ),
            if (widget.module.workflow == 'devis' ||
                widget.module.workflow == 'facture')
              const Text(
                'TVA appliquée : 20 %',
                style: TextStyle(color: AppColors.muted),
              ),
          ],
          const SizedBox(height: 18),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Enregistrement…' : 'Enregistrer'),
          ),
        ],
      ),
    ),
  );

  Widget _fieldWidget(ModuleField field) {
    final controller = _controllers[field.name]!;
    if (field.type == FieldType.checkbox) {
      return CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(field.label),
        value:
            controller.text == '1' || controller.text.toLowerCase() == 'true',
        onChanged: (value) => setState(() {
          controller.text = value == true ? '1' : '0';
        }),
      );
    }
    if (field.type == FieldType.remoteSelect) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _remoteOptions[field.name],
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return InputDecorator(
                decoration: InputDecoration(labelText: field.label),
                child: const Text('Liste indisponible'),
              );
            }
            if (!snapshot.hasData) {
              return InputDecorator(
                decoration: InputDecoration(labelText: field.label),
                child: const LinearProgressIndicator(),
              );
            }
            final rows = snapshot.data!;
            final availableValues = rows
                .map((row) => row['id'].toString())
                .toSet();
            final selected = availableValues.contains(controller.text)
                ? controller.text
                : null;
            return DropdownButtonFormField<String>(
              initialValue: selected,
              decoration: InputDecoration(labelText: field.label),
              items: rows
                  .map(
                    (row) => DropdownMenuItem(
                      value: row['id'].toString(),
                      child: Text(
                        (row[field.remoteLabel] ??
                                row['nom'] ??
                                row['designation'] ??
                                row['reference'] ??
                                'Élément ${row['id']}')
                            .toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) => controller.text = value ?? '',
              validator: field.required
                  ? (value) => value == null ? 'Champ obligatoire.' : null
                  : null,
            );
          },
        ),
      );
    }
    if (field.type == FieldType.select) {
      final current = field.options.containsKey(controller.text)
          ? controller.text
          : null;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DropdownButtonFormField<String>(
          initialValue: current,
          decoration: InputDecoration(labelText: field.label),
          items: field.options.entries
              .map(
                (option) => DropdownMenuItem(
                  value: option.key,
                  child: Text(option.value),
                ),
              )
              .toList(),
          onChanged: (value) => controller.text = value ?? '',
          validator: field.required
              ? (value) => value == null ? 'Champ obligatoire.' : null
              : null,
        ),
      );
    }
    final multiline = field.type == FieldType.textarea;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: switch (field.type) {
          FieldType.number => const TextInputType.numberWithOptions(
            decimal: true,
          ),
          FieldType.email => TextInputType.emailAddress,
          FieldType.phone => TextInputType.phone,
          _ => TextInputType.text,
        },
        maxLines: multiline ? 3 : 1,
        decoration: InputDecoration(labelText: field.label),
        validator: field.required
            ? (value) => value == null || value.trim().isEmpty
                  ? 'Champ obligatoire.'
                  : null
            : null,
      ),
    );
  }

  Widget _lineWidget(int index, Map<String, TextEditingController> row) {
    if (widget.module.lineMode == ModuleLineMode.materiel) {
      return _materielLineWidget(index, row);
    }
    if (widget.module.lineMode == ModuleLineMode.budget) {
      return _budgetLineWidget(index, row);
    }
    return _documentLineWidget(index, row);
  }

  Widget _materielLineWidget(
    int index,
    Map<String, TextEditingController> row,
  ) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Column(
      children: [
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _remoteOptions['materiau_id'],
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return InputDecorator(
                decoration: const InputDecoration(labelText: 'Matériau'),
                child: const Text('Liste des matériaux indisponible'),
              );
            }
            if (!snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: LinearProgressIndicator(),
              );
            }
            final materials = snapshot.data!;
            final values = materials
                .map((item) => item['id'].toString())
                .toSet();
            return DropdownButtonFormField<String>(
              initialValue: values.contains(row['materiau_id']!.text)
                  ? row['materiau_id']!.text
                  : null,
              decoration: InputDecoration(labelText: 'Matériau ${index + 1}'),
              items: materials
                  .map(
                    (item) => DropdownMenuItem(
                      value: item['id'].toString(),
                      child: Text(
                        (item['designation'] ?? item['nom'] ?? 'Matériau')
                            .toString(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              validator: index == 0
                  ? (value) =>
                        value == null ? 'Sélectionnez un matériau.' : null
                  : null,
              onChanged: (value) {
                row['materiau_id']!.text = value ?? '';
                final selected = materials.where(
                  (item) => item['id'].toString() == value,
                );
                if (selected.isNotEmpty) {
                  row['designation']!.text =
                      selected.first['designation']?.toString() ?? '';
                  row['unite']!.text =
                      selected.first['unite']?.toString() ?? 'U';
                }
              },
            );
          },
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: row['quantite_demandee'],
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Quantité'),
                validator: index == 0
                    ? (value) => (num.tryParse(value ?? '') ?? 0) <= 0
                          ? 'Quantité invalide.'
                          : null
                    : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: row['unite'],
                decoration: const InputDecoration(labelText: 'Unité'),
              ),
            ),
            if (_lines.length > 1)
              IconButton(
                tooltip: 'Supprimer la ligne',
                onPressed: () => setState(() {
                  final removed = _lines.removeAt(index);
                  for (final controller in removed.values) {
                    controller.dispose();
                  }
                }),
                icon: const Icon(Icons.delete_outline),
              ),
          ],
        ),
      ],
    ),
  );

  Widget _budgetLineWidget(
    int index,
    Map<String, TextEditingController> row,
  ) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: row['rubrique'],
            decoration: InputDecoration(labelText: 'Rubrique ${index + 1}'),
            validator: index == 0
                ? (value) => value == null || value.trim().isEmpty
                      ? 'Une rubrique est requise.'
                      : null
                : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: row['montant_prevu'],
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Montant prévu (Ar)'),
          ),
        ),
        if (_lines.length > 1)
          IconButton(
            tooltip: 'Supprimer la ligne',
            onPressed: () => setState(() {
              final removed = _lines.removeAt(index);
              for (final controller in removed.values) {
                controller.dispose();
              }
            }),
            icon: const Icon(Icons.delete_outline),
          ),
      ],
    ),
  );

  Widget _documentLineWidget(
    int index,
    Map<String, TextEditingController> row,
  ) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Column(
      children: [
        TextFormField(
          controller: row['designation'],
          decoration: InputDecoration(labelText: 'Désignation ${index + 1}'),
          validator: index == 0
              ? (value) => value == null || value.trim().isEmpty
                    ? 'Une ligne est requise.'
                    : null
              : null,
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: row['quantite'],
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Quantité'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: row['prix_unitaire'],
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Prix unitaire (Ar)',
                ),
              ),
            ),
            if (_lines.length > 1)
              IconButton(
                tooltip: 'Supprimer la ligne',
                onPressed: () => setState(() {
                  final removed = _lines.removeAt(index);
                  for (final controller in removed.values) {
                    controller.dispose();
                  }
                }),
                icon: const Icon(Icons.delete_outline),
              ),
          ],
        ),
      ],
    ),
  );

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final body = <String, dynamic>{};
    for (final field in _fields) {
      final value = _controllers[field.name]!.text.trim();
      if (field.type == FieldType.checkbox) {
        body[field.name] = value == '1' || value.toLowerCase() == 'true';
      } else if (value.isNotEmpty) {
        body[field.name] =
            field.type == FieldType.number ||
                field.type == FieldType.remoteSelect
            ? num.tryParse(value) ?? value
            : value;
      }
    }
    if (widget.module.hasLines) {
      body['lignes'] = switch (widget.module.lineMode) {
        ModuleLineMode.document =>
          _lines
              .where((line) => line['designation']!.text.trim().isNotEmpty)
              .map(
                (line) => {
                  'designation': line['designation']!.text.trim(),
                  'quantite': num.tryParse(line['quantite']!.text) ?? 1,
                  'prix_unitaire':
                      int.tryParse(line['prix_unitaire']!.text) ?? 0,
                },
              )
              .toList(),
        ModuleLineMode.materiel =>
          _lines
              .where((line) => line['materiau_id']!.text.trim().isNotEmpty)
              .map(
                (line) => {
                  'materiau_id': int.tryParse(line['materiau_id']!.text),
                  'designation': line['designation']!.text.trim(),
                  'unite': line['unite']!.text.trim(),
                  'quantite_demandee':
                      num.tryParse(line['quantite_demandee']!.text) ?? 0,
                },
              )
              .toList(),
        ModuleLineMode.budget =>
          _lines
              .where((line) => line['rubrique']!.text.trim().isNotEmpty)
              .map(
                (line) => {
                  'rubrique': line['rubrique']!.text.trim(),
                  'montant_prevu':
                      num.tryParse(line['montant_prevu']!.text) ?? 0,
                },
              )
              .toList(),
      };
      if (widget.module.workflow == 'devis' ||
          widget.module.workflow == 'facture') {
        body['tva_taux'] = 20;
      }
    }
    try {
      if (_editing) {
        await widget.api.put(
          '${widget.module.endpoint}/${widget.initial!['id']}',
          body,
        );
      } else if (widget.module.workflow == 'stock') {
        await widget.api.post('mouvements', body);
      } else {
        await widget.api.post(widget.module.endpoint, body);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class RecordDetailScreen extends StatefulWidget {
  const RecordDetailScreen({
    required this.api,
    required this.module,
    required this.role,
    required this.item,
    super.key,
  });

  final ApiClient api;
  final AppModule module;
  final String role;
  final Map<String, dynamic> item;

  @override
  State<RecordDetailScreen> createState() => _RecordDetailScreenState();
}

class _RecordDetailScreenState extends State<RecordDetailScreen> {
  late Future<Map<String, dynamic>> _record;

  @override
  void initState() {
    super.initState();
    _record = _load();
  }

  Future<Map<String, dynamic>> _load() async {
    if (widget.module.workflow == 'stock') {
      final movements =
          await widget.api.getData('materiaux/${widget.item['id']}/mouvements')
              as List;
      return {...widget.item, 'mouvements': movements};
    }
    final record = Map<String, dynamic>.from(
      await widget.api.getData('${widget.module.endpoint}/${widget.item['id']}')
          as Map,
    );
    if (widget.module.workflow == 'depense' &&
        ['directeur', 'comptable'].contains(widget.role)) {
      final response = await widget.api.getData(
        'validations?type_operation=depense&operation_id=${widget.item['id']}',
      );
      final rows = response is List
          ? response
          : (response as Map)['elements'] as List? ?? [];
      final validation = rows.whereType<Map>().firstOrNull;
      record['role_attendu'] =
          validation?['role_attendu'] ??
          (record['statut'] == 'brouillon' ? 'comptable' : null);
    }
    return record;
  }

  bool get _canEditRecord =>
      widget.module.canEdit(widget.role) &&
      widget.module.updatable &&
      widget.module.fields.isNotEmpty &&
      widget.module.workflow != 'achat' &&
      widget.module.workflow != 'devis' &&
      widget.module.workflow != 'facture';

  bool get _canDeleteRecord =>
      widget.module.canDelete(widget.role) && widget.module.deletable;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.module.title),
      actions: [
        if (_canEditRecord || _canDeleteRecord)
          PopupMenuButton<String>(
            tooltip: 'Actions',
            icon: const Icon(Icons.more_vert),
            onSelected: (action) {
              if (action == 'edit') _edit(widget.item);
              if (action == 'delete') _delete();
            },
            itemBuilder: (_) => [
              if (_canEditRecord)
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 20),
                      SizedBox(width: 10),
                      Text('Modifier'),
                    ],
                  ),
                ),
              if (_canDeleteRecord)
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Color(0xFF9C422B),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Supprimer',
                        style: TextStyle(color: Color(0xFF9C422B)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
      ],
    ),
    body: FutureBuilder<Map<String, dynamic>>(
      future: _record,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!;
        final decisionActions = _headerDecisionActions(data);
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (decisionActions.isNotEmpty)
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Actions',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: decisionActions,
                      ),
                    ],
                  ),
                ),
              ),
            if (widget.module.workflow == 'chantier')
              _chantierDetails(data)
            else
              _recordDetails(data),
            if (widget.module.workflow == 'chantier') _chantierWorkspace(data),
            if (data['lignes'] is List) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Lignes',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              ...(data['lignes'] as List).whereType<Map>().map((line) {
                final subtitle = switch (widget.module.lineMode) {
                  ModuleLineMode.materiel =>
                    '${line['quantite_demandee'] ?? ''} ${line['unite'] ?? ''}',
                  ModuleLineMode.budget =>
                    'Prévu : ${line['montant_prevu'] ?? 0} Ar · Engagé : ${line['montant_engage'] ?? 0} Ar',
                  ModuleLineMode.document =>
                    '${line['quantite'] ?? ''} × ${line['prix_unitaire'] ?? ''} Ar',
                };
                return ListTile(
                  title: Text(
                    '${line['designation'] ?? line['rubrique'] ?? 'Ligne'}',
                  ),
                  subtitle: Text(subtitle),
                );
              }),
            ],
            if (data['paiements'] is List)
              ...(data['paiements'] as List).whereType<Map>().map(
                (p) => ListTile(
                  title: Text('Paiement ${p['date_paiement'] ?? ''}'),
                  trailing: Text('${p['montant'] ?? 0} Ar'),
                ),
              ),
            if (data['mouvements'] is List) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Historique des mouvements',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              ...(data['mouvements'] as List).whereType<Map>().map(
                (movement) => ListTile(
                  leading: Icon(
                    movement['type'] == 'entree'
                        ? Icons.south_west
                        : Icons.north_east,
                    color: movement['type'] == 'entree'
                        ? AppColors.forest
                        : const Color(0xFF9C422B),
                  ),
                  title: Text(
                    '${movement['type'] ?? 'Mouvement'} · ${movement['quantite'] ?? 0} ${widget.item['unite'] ?? ''}',
                  ),
                  subtitle: Text(
                    [
                          movement['date_mouvement'],
                          movement['motif'],
                          movement['chantier_nom'],
                        ]
                        .where(
                          (value) =>
                              value != null && value.toString().isNotEmpty,
                        )
                        .join(' · '),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (_hasWorkflowAction(data) && decisionActions.isEmpty)
              _workflowButtons(data),
          ],
        );
      },
    ),
  );

  bool _hasWorkflowAction(Map<String, dynamic> data) =>
      switch (widget.module.workflow) {
        'achat' =>
          widget.role == 'magasinier' &&
              data['statut'] != 'recu' &&
              data['statut'] != 'annule',
        'devis' => widget.role == 'comptable' && data['statut'] != 'refuse',
        'facture' => widget.role == 'comptable' && data['statut'] != 'annulee',
        'demande_materiel' =>
          (data['statut'] == 'en_attente' && widget.role == 'directeur') ||
              (data['statut'] == 'valide' && widget.role == 'magasinier'),
        'rapport' => data['statut'] == 'brouillon',
        'depense' =>
          (data['statut'] == 'rejete' &&
                  widget.module.canCreate(widget.role)) ||
              (['en_attente', 'brouillon'].contains(data['statut']) &&
                  data['role_attendu'] == widget.role),
        'rfi' => data['statut'] == 'ouvert',
        'validation' =>
          data['statut'] == 'en_attente' && data['role_attendu'] == widget.role,
        _ => false,
      };

  bool get _canViewFinancials =>
      widget.role == 'directeur' || widget.role == 'comptable';

  List<Widget> _headerDecisionActions(Map<String, dynamic> data) {
    final canDecideMaterialRequest =
        widget.module.workflow == 'demande_materiel' &&
        data['statut'] == 'en_attente' &&
        widget.role == 'directeur' &&
        widget.module.canWorkflow(widget.role);
    final canDecideExpense =
        widget.module.workflow == 'depense' &&
        ['en_attente', 'brouillon'].contains(data['statut']) &&
        data['role_attendu'] == widget.role;
    final canDecideValidation =
        widget.module.workflow == 'validation' &&
        data['role_attendu'] == widget.role;

    if (canDecideMaterialRequest || canDecideExpense || canDecideValidation) {
      final isExpense = widget.module.workflow == 'depense';
      final isValidation = widget.module.workflow == 'validation';
      final rejectField = isExpense
          ? 'motif_rejet'
          : isValidation
          ? 'motif'
          : 'motif_refus';
      final rejectTitle = isExpense
          ? 'Refuser la dépense'
          : 'Refuser la demande';

      return [
        FilledButton.icon(
          onPressed: () => _action(
            'POST',
            isExpense || isValidation ? 'valider' : 'approuver',
            {},
          ),
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Approuver'),
        ),
        OutlinedButton.icon(
          onPressed: () => _reasonDialog(
            title: rejectTitle,
            field: rejectField,
            action: isExpense ? 'rejeter' : 'refuser',
          ),
          icon: const Icon(Icons.cancel_outlined),
          label: const Text('Refuser'),
        ),
      ];
    }

    return [];
  }

  Widget _recordDetails(Map<String, dynamic> data) {
    final fieldsByName = {
      for (final field in widget.module.fields) field.name: field,
    };
    // Le champ principal (nom, reference...) est mis en avant dans l'entete :
    // on l'ecarte de la liste "Informations" pour eviter un doublon.
    final titleKeys = const [
      'nom',
      'designation',
      'reference',
      'libelle',
      'code',
    ];
    final titleKey = titleKeys.firstWhere(
      (key) => data[key] != null && data[key].toString().trim().isNotEmpty,
      orElse: () => '',
    );
    final relationLabelKeys = <String>{};
    final entries = <MapEntry<String, dynamic>>[];
    for (final field in widget.module.fields) {
      if (field.name == titleKey ||
          !data.containsKey(field.name) ||
          data[field.name] == null) {
        continue;
      }
      if (field.type == FieldType.remoteSelect && field.name.endsWith('_id')) {
        final labelKey =
            '${field.name.substring(0, field.name.length - 3)}_nom';
        relationLabelKeys.add(labelKey);
        final label = data[labelKey];
        if (label != null && label.toString().trim().isNotEmpty) {
          entries.add(MapEntry(field.name, label));
        }
        continue;
      }
      entries.add(MapEntry(field.name, data[field.name]));
    }
    for (final entry in data.entries) {
      if (entry.key == titleKey ||
          fieldsByName.containsKey(entry.key) ||
          relationLabelKeys.contains(entry.key) ||
          entry.key.endsWith('_id') ||
          (entry.key.endsWith('_nom') &&
              !relationLabelKeys.contains(entry.key)) ||
          data.containsKey('${entry.key}_nom') ||
          const {
            'id',
            'lignes',
            'paiements',
            'mouvements',
          }.contains(entry.key) ||
          entry.value == null ||
          entry.value is Map ||
          entry.value is List) {
        continue;
      }
      entries.add(entry);
    }
    for (final entry in data.entries.where(
      (entry) =>
          entry.key.endsWith('_nom') && !relationLabelKeys.contains(entry.key),
    )) {
      final baseKey = entry.key.substring(0, entry.key.length - 4);
      if (entry.value != null && entry.value.toString().trim().isNotEmpty) {
        entries.add(MapEntry(baseKey, entry.value));
      }
    }
    final title = titleKey.isEmpty
        ? '${widget.module.title} #${data['id'] ?? ''}'
        : data[titleKey];
    final status = data['statut']?.toString();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.lime,
                      child: Icon(
                        widget.module.icon,
                        color: AppColors.forest,
                        size: 25,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.toString(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                          if (status != null && status.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _ChantierStatus(status: status),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informations',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final entry in entries)
                      _DetailValue(
                        label:
                            fieldsByName[entry.key]?.label ??
                            _label(
                              entry.key.endsWith('_nom')
                                  ? entry.key.substring(0, entry.key.length - 4)
                                  : entry.key,
                            ),
                        value: _displayValue(
                          entry.key,
                          entry.value,
                          fieldsByName[entry.key],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _displayValue(String key, dynamic value, [ModuleField? field]) {
    final code = value.toString();
    final option = field?.options[code];
    if (option != null) return option;
    if (key == 'actif' || key == 'valide' || key == 'est_actif') {
      return value == true || code == '1' ? 'Oui' : 'Non';
    }
    if (key == 'statut' || key == 'etat') {
      return labelStatut(value);
    }
    if (key.startsWith('date_') ||
        key == 'date_devis' ||
        key == 'date_facture' ||
        key == 'echeance') {
      return formatDate(value);
    }
    if (key.contains('budget') ||
        key.contains('montant') ||
        key.contains('prix') ||
        key.contains('cout') ||
        key == 'taux_journalier') {
      return formatMontant(value);
    }
    return value.toString();
  }

  Widget _chantierDetails(Map<String, dynamic> data) {
    final stats = Map<String, dynamic>.from(data['stats'] as Map? ?? {});
    final avancement =
        (num.tryParse(stats['avancement_global']?.toString() ?? '') ?? 0).clamp(
          0,
          100,
        );
    final informations = <(String, String)>[
      ('Code', data['code']?.toString() ?? ''),
      ('Type', _chantierType(data['type']?.toString())),
      ('Client', data['client_nom']?.toString() ?? ''),
      ('Responsable', data['responsable_nom']?.toString() ?? ''),
      ('Localisation', data['localisation']?.toString() ?? ''),
      ('Date de début', formatDate(data['date_debut'])),
      ('Fin prévue', formatDate(data['date_fin_prevue'])),
      ('Fin réelle', formatDate(data['date_fin_reelle'])),
      ('Description', data['description']?.toString() ?? ''),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data['nom']?.toString() ?? 'Chantier',
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    _ChantierStatus(status: data['statut']?.toString() ?? ''),
                  ],
                ),
                const SizedBox(height: 14),
                for (final (label, value) in informations)
                  if (value.trim().isNotEmpty)
                    _DetailValue(label: label, value: value),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Avancement global',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(value: avancement / 100),
                const SizedBox(height: 8),
                Text(
                  '${avancement.toStringAsFixed(0)} % · ${stats['nb_lots'] ?? 0} lot(s)',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_canViewFinancials) ...[
                  const Divider(height: 24),
                  _DetailValue(
                    label: 'Budget prévisionnel',
                    value: formatMontant(data['budget_previsionnel']),
                  ),
                  _DetailValue(
                    label: 'Budget des lots',
                    value: formatMontant(stats['budget_lots']),
                  ),
                  _DetailValue(
                    label: 'Coût main-d’œuvre',
                    value: formatMontant(stats['cout_main_oeuvre']),
                  ),
                  _DetailValue(
                    label: 'Coût matériaux',
                    value: formatMontant(stats['cout_materiaux']),
                  ),
                  _DetailValue(
                    label: 'Coût total engagé',
                    value: formatMontant(stats['cout_total']),
                  ),
                  _DetailValue(
                    label: 'Reste sur budget',
                    value: formatMontant(stats['reste_budget']),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _chantierType(String? type) => switch (type) {
    'batiment' => 'Bâtiment',
    'route' => 'Route / travaux publics',
    'autre' => 'Autre',
    null || '' => '',
    _ => type,
  };

  Widget _chantierWorkspace(Map<String, dynamic> data) {
    final lots = List<Map<String, dynamic>>.from(data['lots'] as List? ?? []);
    final canEdit = widget.module.canEdit(widget.role);
    final canDeleteLot =
        widget.role == 'directeur' || widget.role == 'chef_chantier';
    final id = int.parse(widget.item['id'].toString());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Text(
            'Lots et avancement',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
        ),
        if (lots.isEmpty)
          const Card(child: ListTile(title: Text('Aucun lot enregistré.'))),
        ...lots.map(
          (lot) => Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lot['nom']?.toString() ?? 'Lot',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      if (canEdit || canDeleteLot)
                        PopupMenuButton<String>(
                          onSelected: (action) {
                            if (action == 'modifier') _editLot(id, lot: lot);
                            if (action == 'supprimer') _deleteLot(lot);
                          },
                          itemBuilder: (_) => [
                            if (canEdit)
                              const PopupMenuItem(
                                value: 'modifier',
                                child: Text('Modifier'),
                              ),
                            if (canDeleteLot)
                              const PopupMenuItem(
                                value: 'supprimer',
                                child: Text('Supprimer'),
                              ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value:
                        ((num.tryParse(lot['avancement']?.toString() ?? '') ??
                                0)
                            .clamp(0, 100)) /
                        100,
                  ),
                  const SizedBox(height: 8),
                  _DetailValue(
                    label: 'Avancement',
                    value: '${lot['avancement'] ?? 0} %',
                  ),
                  _DetailValue(
                    label: 'Statut',
                    value: _label(lot['statut']?.toString() ?? ''),
                  ),
                  if (_canViewFinancials)
                    _DetailValue(
                      label: 'Budget',
                      value: formatMontant(lot['budget_previsionnel']),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (canEdit) ...[
          OutlinedButton.icon(
            onPressed: () => _editLot(id),
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un lot'),
          ),
          const SizedBox(height: 8),
        ],
        if (widget.module.canRead(widget.role))
          FilledButton.icon(
            onPressed: () async {
              await Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => PointageScreen(
                    api: widget.api,
                    chantierId: id,
                    chantierNom: data['nom']?.toString() ?? 'Chantier',
                    role: widget.role,
                  ),
                ),
              );
              if (mounted) {
                setState(() {
                  _record = _load();
                });
              }
            },
            icon: const Icon(Icons.fact_check_outlined),
            label: const Text('Consulter la feuille de pointage'),
          ),
      ],
    );
  }

  Future<void> _editLot(int chantierId, {Map<String, dynamic>? lot}) async {
    final form = GlobalKey<FormState>();
    final name = TextEditingController(text: lot?['nom']?.toString() ?? '');
    final budget = TextEditingController(
      text: lot?['budget_previsionnel']?.toString() ?? '0',
    );
    final progress = TextEditingController(
      text: lot?['avancement']?.toString() ?? '0',
    );
    final order = TextEditingController(text: lot?['ordre']?.toString() ?? '0');
    var status = lot?['statut']?.toString() ?? 'a_faire';
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(lot == null ? 'Ajouter un lot' : 'Modifier le lot'),
          content: Form(
            key: form,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'Nom'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Nom obligatoire.'
                        : null,
                  ),
                  TextField(
                    controller: budget,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Budget prévisionnel (Ar)',
                    ),
                  ),
                  TextField(
                    controller: progress,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Avancement (%)',
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    decoration: const InputDecoration(labelText: 'Statut'),
                    items: const [
                      DropdownMenuItem(
                        value: 'a_faire',
                        child: Text('À faire'),
                      ),
                      DropdownMenuItem(
                        value: 'en_cours',
                        child: Text('En cours'),
                      ),
                      DropdownMenuItem(
                        value: 'termine',
                        child: Text('Terminé'),
                      ),
                    ],
                    onChanged: (value) =>
                        setDialogState(() => status = value ?? 'a_faire'),
                  ),
                  TextField(
                    controller: order,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Ordre'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                if (form.currentState!.validate()) Navigator.pop(context, true);
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
    if (saved == true) {
      try {
        final body = {
          'nom': name.text.trim(),
          'budget_previsionnel': int.tryParse(budget.text) ?? 0,
          'avancement': (int.tryParse(progress.text) ?? 0).clamp(0, 100),
          'statut': status,
          'ordre': int.tryParse(order.text) ?? 0,
        };
        if (lot == null) {
          await widget.api.post('chantiers/$chantierId/lots', body);
        } else {
          await widget.api.put('lots/${lot['id']}', body);
        }
        if (mounted) {
          setState(() {
            _record = _load();
          });
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error.toString())));
        }
      }
    }
    name.dispose();
    budget.dispose();
    progress.dispose();
    order.dispose();
  }

  Future<void> _deleteLot(Map<String, dynamic> lot) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce lot ?'),
        content: const Text('Cette action ne peut pas être annulée.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Garder'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await widget.api.delete('lots/${lot['id']}');
      if (mounted) {
        setState(() {
          _record = _load();
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Widget _workflowButtons(Map<String, dynamic> data) {
    if (!widget.module.canWorkflow(widget.role)) {
      return const SizedBox.shrink();
    }
    return Column(
      children: switch (widget.module.workflow) {
        'achat' => [
          FilledButton.icon(
            onPressed: () => _action('POST', 'reception', {}),
            icon: const Icon(Icons.inventory),
            label: const Text('Réceptionner l’achat'),
          ),
          if (widget.module.canDelete(widget.role) &&
              data['statut'] != 'annule')
            OutlinedButton.icon(
              onPressed: () => _action('POST', 'annuler', {}),
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Annuler l’achat'),
            ),
        ],
        'devis' => [
          OutlinedButton.icon(
            onPressed: () => _changeQuoteStatus(data),
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Changer le statut'),
          ),
          FilledButton.icon(
            onPressed: () => _action('POST', 'facturer', {}),
            icon: const Icon(Icons.receipt_long),
            label: const Text('Créer une facture'),
          ),
        ],
        'facture' => [
          if (data['statut'] == 'brouillon')
            FilledButton.icon(
              onPressed: () => _action('POST', 'emettre', {}),
              icon: const Icon(Icons.send),
              label: const Text('Émettre la facture'),
            ),
          if (data['statut'] != 'brouillon')
            OutlinedButton.icon(
              onPressed: () => _paymentDialog(),
              icon: const Icon(Icons.payments_outlined),
              label: const Text('Ajouter un paiement'),
            ),
          if (widget.module.canDelete(widget.role) &&
              data['statut'] != 'annulee')
            OutlinedButton.icon(
              onPressed: () => _action('POST', 'annuler', {}),
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Annuler la facture'),
            ),
        ],
        'demande_materiel' => [
          if (data['statut'] == 'valide' && widget.role == 'magasinier')
            FilledButton.icon(
              onPressed: () => _action('POST', 'traiter', {}),
              icon: const Icon(Icons.inventory_2_outlined),
              label: const Text('Traiter la demande'),
            ),
        ],
        'depense' => [
          if (data['statut'] == 'rejete' &&
              widget.module.canCreate(widget.role))
            FilledButton.icon(
              onPressed: () => _action('POST', 'soumettre', {}),
              icon: const Icon(Icons.send_outlined),
              label: const Text('Soumettre à nouveau'),
            ),
        ],
        'rapport' => [
          FilledButton.icon(
            onPressed: () => _action('POST', 'soumettre', {}),
            icon: const Icon(Icons.send_outlined),
            label: const Text('Soumettre le rapport'),
          ),
        ],
        'rfi' => [
          FilledButton.icon(
            onPressed: _replyRfi,
            icon: const Icon(Icons.reply_outlined),
            label: const Text('Répondre à la RFI'),
          ),
        ],
        'validation' => [],
        _ => <Widget>[],
      },
    );
  }

  Future<void> _reasonDialog({
    required String title,
    required String field,
    required String action,
  }) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Motif obligatoire'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (reason != null) {
      await _action('POST', action, {field: reason});
    }
  }

  Future<void> _replyRfi() async {
    final controller = TextEditingController();
    final reply = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Répondre à la RFI'),
        content: TextField(
          controller: controller,
          minLines: 3,
          maxLines: 6,
          decoration: const InputDecoration(labelText: 'Réponse'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (reply != null) await _action('POST', 'repondre', {'reponse': reply});
  }

  Future<void> _changeQuoteStatus(Map<String, dynamic> data) async {
    final status = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final value in ['brouillon', 'envoye', 'accepte', 'refuse'])
              ListTile(
                title: Text(value),
                onTap: () => Navigator.pop(context, value),
              ),
          ],
        ),
      ),
    );
    if (status != null) _action('PUT', 'statut', {'statut': status});
  }

  Future<void> _paymentDialog() async {
    final amount = TextEditingController();
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un paiement'),
        content: TextField(
          controller: amount,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Montant (Ar)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    if (accepted == true) {
      await _action('POST', 'paiements', {
        'montant': int.tryParse(amount.text) ?? 0,
        'mode': 'especes',
      });
    }
    amount.dispose();
  }

  Future<void> _action(
    String method,
    String action,
    Map<String, dynamic> body,
  ) async {
    try {
      final path = '${widget.module.endpoint}/${widget.item['id']}/$action';
      if (method == 'PUT') {
        await widget.api.put(path, body);
      } else {
        await widget.api.post(path, body);
      }
      if (mounted) {
        setState(() {
          _record = _load();
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Future<void> _edit(Map<String, dynamic> data) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => ModuleFormScreen(
          api: widget.api,
          module: widget.module,
          role: widget.role,
          initial: data,
        ),
      ),
    );
    if (saved == true && mounted) {
      setState(() {
        _record = _load();
      });
      Navigator.pop(context, true);
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cet élément ?'),
        content: const Text('Cette action ne peut pas être annulée.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await widget.api.delete('${widget.module.endpoint}/${widget.item['id']}');
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }
}

String _label(String value) => value
    .replaceAll('_', ' ')
    .replaceFirstMapped(RegExp(r'^[a-z]'), (match) => match[0]!.toUpperCase());

class _ChantierStatus extends StatelessWidget {
  const _ChantierStatus({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = Color(couleurStatut(status));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        labelStatut(status),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DetailValue extends StatelessWidget {
  const _DetailValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 112,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.muted),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
