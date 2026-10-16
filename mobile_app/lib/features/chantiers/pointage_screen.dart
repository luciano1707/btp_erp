import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../shared/app_theme.dart';

class PointageScreen extends StatefulWidget {
  const PointageScreen({required this.api, required this.chantierId, required this.chantierNom, required this.role, super.key});

  final ApiClient api;
  final int chantierId;
  final String chantierNom;
  final String role;

  @override
  State<PointageScreen> createState() => _PointageScreenState();
}

class _PointageScreenState extends State<PointageScreen> {
  DateTime _date = DateTime.now();
  List<Map<String, dynamic>> _employees = [];
  List<Map<String, dynamic>> _lots = [];
  final Map<int, String> _presence = {};
  final Map<int, String> _lot = {};
  bool _loading = true;
  bool _saving = false;
  String? _error;

  bool get _canEdit => widget.role == 'directeur' || widget.role == 'chef_chantier';
  bool get _canViewCost => widget.role == 'directeur' || widget.role == 'comptable';
  String get _dateValue => '${_date.year.toString().padLeft(4, '0')}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        widget.api.getData('employes?limite=200'),
        widget.api.getData('chantiers/${widget.chantierId}'),
      ]);
      final employeeResponse = results[0] as Map;
      _employees = List<Map<String, dynamic>>.from(employeeResponse['elements'] as List)
          .where((employee) => employee['actif'] == true || employee['actif'].toString() == '1')
          .toList();
      _lots = List<Map<String, dynamic>>.from((results[1] as Map)['lots'] as List? ?? []);
      await _loadSheet();
    } catch (error) {
      _error = error.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadSheet() async {
    final response = await widget.api.getData('chantiers/${widget.chantierId}/pointages?date=$_dateValue') as List;
    _presence.clear();
    _lot.clear();
    for (final row in response.whereType<Map>()) {
      final id = int.tryParse(row['employe_id'].toString());
      if (id == null) continue;
      _presence[id] = row['type_presence']?.toString() ?? 'absent';
      _lot[id] = row['lot_id']?.toString() ?? '';
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Pointage · ${widget.chantierNom}', maxLines: 1, overflow: TextOverflow.ellipsis),
      actions: [IconButton(tooltip: 'Choisir la date', onPressed: _chooseDate, icon: const Icon(Icons.calendar_month_outlined))],
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
            ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!, textAlign: TextAlign.center)))
            : Column(children: [
                ListTile(title: const Text('Date de pointage'), subtitle: Text(_dateValue), trailing: TextButton(onPressed: _chooseDate, child: const Text('Modifier'))),
                Expanded(child: _employees.isEmpty
                    ? const Center(child: Text('Aucun employé actif dans les référentiels.'))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: _employees.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) => _employeeCard(_employees[index]),
                      )),
                if (_canEdit) SafeArea(top: false, child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _saving ? null : _save, icon: const Icon(Icons.save_outlined), label: Text(_saving ? 'Enregistrement…' : 'Enregistrer la feuille'))),
                )),
              ]),
  );

  Widget _employeeCard(Map<String, dynamic> employee) {
    final id = int.parse(employee['id'].toString());
    final name = '${employee['prenom'] ?? ''} ${employee['nom'] ?? ''}'.trim();
    final dailyRate = int.tryParse(employee['taux_journalier']?.toString() ?? '') ?? 0;
    final presence = _presence[id] ?? 'absent';
    final coefficient = presence == 'journee' ? 1.0 : presence == 'demi_journee' ? 0.5 : 0.0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name.isEmpty ? 'Employé ${employee['id']}' : name, style: const TextStyle(fontWeight: FontWeight.w700)),
        Text(
          _canViewCost
              ? '${employee['poste'] ?? 'Poste non renseigné'} · Taux : $dailyRate Ar/jour'
              : (employee['poste']?.toString() ?? 'Poste non renseigné'),
          style: const TextStyle(color: AppColors.muted, fontSize: 12),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: presence,
          decoration: const InputDecoration(labelText: 'Présence'),
          items: const [
            DropdownMenuItem(value: 'journee', child: Text('Journée complète')),
            DropdownMenuItem(value: 'demi_journee', child: Text('Demi-journée')),
            DropdownMenuItem(value: 'absent', child: Text('Absent')),
          ],
          onChanged: _canEdit ? (value) => setState(() => _presence[id] = value ?? 'absent') : null,
        ),
        if (_lots.isNotEmpty) ...[
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _lot[id] ?? '',
            decoration: const InputDecoration(labelText: 'Lot associé'),
            items: [const DropdownMenuItem(value: '', child: Text('Aucun lot')), ..._lots.map((lot) => DropdownMenuItem(value: lot['id'].toString(), child: Text(lot['nom'].toString())))],
            onChanged: _canEdit ? (value) => setState(() => _lot[id] = value ?? '') : null,
          ),
        ],
        const SizedBox(height: 8),
        if (_canViewCost)
          Text(
            'Coût de la journée : ${(dailyRate * coefficient).round()} Ar',
            style: const TextStyle(color: AppColors.forest, fontWeight: FontWeight.w700),
          ),
      ]),
    );
  }

  Future<void> _chooseDate() async {
    final selected = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (selected == null) return;
    setState(() { _date = selected; _loading = true; });
    try {
      await _loadSheet();
    } catch (error) {
      _error = error.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await widget.api.post('chantiers/${widget.chantierId}/pointages', {
        'date': _dateValue,
        'lignes': _employees.map((employee) {
          final id = int.parse(employee['id'].toString());
          return {
            'employe_id': id,
            'type_presence': _presence[id] ?? 'absent',
            'lot_id': (_lot[id] ?? '').isEmpty ? null : int.tryParse(_lot[id]!),
          };
        }).toList(),
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feuille de pointage enregistrée.')));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}