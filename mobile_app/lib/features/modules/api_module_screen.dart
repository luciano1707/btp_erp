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

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final suffix = _search.text.trim().isEmpty
          ? ''
          : '?recherche=${Uri.encodeQueryComponent(_search.text.trim())}';
      final response = await widget.api.getData(
        '${widget.module.endpoint}$suffix',
      );
      final records = response is List
          ? response
          : (response as Map)['elements'] as List? ?? [];
      _items = List<Map<String, dynamic>>.from(records);
    } catch (error) {
      _error = error.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
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
            onSubmitted: (_) => _load(),
            decoration: InputDecoration(
              labelText: 'Rechercher',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                onPressed: _load,
                icon: const Icon(Icons.arrow_forward),
              ),
            ),
          ),
        ),
        Expanded(
          child: _loading && _items.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _error != null && _items.isEmpty
              ? ErrorPanel(message: _error!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: _items.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.sizeOf(context).height * .28,
                            ),
                            const Center(child: Text('Aucun élément.')),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                          itemCount: _items.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) => _ModuleRecordTile(
                            item: _items[index],
                            module: widget.module,
                            onTap: () => _open(_items[index]),
                            onEdit: _canEditRecord
                                ? () => _edit(_items[index])
                                : null,
                            onDelete: _canDeleteRecord
                                ? () => _deleteRecord(_items[index])
                                : null,
                          ),
                        ),
                ),
        ),
      ],
    ),
  );

  Future<void> _edit([Map<String, dynamic>? item]) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => ModuleFormScreen(
          api: widget.api,
          module: widget.module,
          role: widget.role,
          initial: item,
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
    final title =
        item['nom'] ??
        item['designation'] ??
        item['reference'] ??
        item['libelle'] ??
        item['code'] ??
        'Élément ${item['id'] ?? ''}';
    final subtitle =
        [
              item['statut'],
              item['localisation'],
              item['client_nom'],
              item['fournisseur_nom'],
              item['date_achat'],
              item['date_facture'],
            ]
            .where((value) => value != null && value.toString().isNotEmpty)
            .join(' · ');
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
                  color: const Color(0xFFE8F0D8),
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
                    if (statut != null && statut.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _StatutPuce(statut: statut),
                    ] else if (subtitle.isNotEmpty) ...[
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
    if (widget.module.hasLines) _addLine();
  }

  void _addLine() => _lines.add({
    'designation': TextEditingController(),
    'quantite': TextEditingController(text: '1'),
    'prix_unitaire': TextEditingController(),
  });

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

  Widget _lineWidget(int index, Map<String, TextEditingController> row) =>
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          children: [
            TextFormField(
              controller: row['designation'],
              decoration: InputDecoration(
                labelText: 'Désignation ${index + 1}',
              ),
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
                      _lines.removeAt(index);
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
      body['lignes'] = _lines
          .where((line) => line['designation']!.text.trim().isNotEmpty)
          .map(
            (line) => {
              'designation': line['designation']!.text.trim(),
              'quantite': num.tryParse(line['quantite']!.text) ?? 1,
              'prix_unitaire': int.tryParse(line['prix_unitaire']!.text) ?? 0,
            },
          )
          .toList();
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
    return Map<String, dynamic>.from(
      await widget.api.getData('${widget.module.endpoint}/${widget.item['id']}')
          as Map,
    );
  }

  bool get _canEditRecord =>
      widget.module.canEdit(widget.role) &&
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
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
              ...(data['lignes'] as List).whereType<Map>().map(
                (line) => ListTile(
                  title: Text('${line['designation'] ?? 'Ligne'}'),
                  subtitle: Text(
                    '${line['quantite'] ?? ''} × ${line['prix_unitaire'] ?? ''} Ar',
                  ),
                ),
              ),
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
            if (_hasWorkflowAction(data)) _workflowButtons(data),
          ],
        );
      },
    ),
  );

  bool _hasWorkflowAction(Map<String, dynamic> data) =>
      switch (widget.module.workflow) {
        'achat' => data['statut'] != 'recu' && data['statut'] != 'annule',
        'devis' => data['statut'] != 'refuse',
        'facture' => data['statut'] != 'annulee',
        _ => false,
      };

  bool get _canViewFinancials =>
      widget.role == 'directeur' || widget.role == 'comptable';

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
                      backgroundColor: const Color(0xFFE8F0D8),
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
    if (!widget.module.canWrite(widget.role)) return const SizedBox.shrink();
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
        _ => <Widget>[],
      },
    );
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
