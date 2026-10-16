import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../shared/app_theme.dart';
import '../../shared/charts.dart';
import '../../shared/labels.dart';
import '../../shared/widgets.dart';
import '../modules/module_catalog.dart';

/// Ecran Stock : reprend la page `stock/index.php` du back-office web.
///
/// Affiche l'etat courant par materiau (niveau, seuil d'alerte) et permet
/// d'enregistrer les mouvements : entree, sortie de chantier, ajustement.
/// L'API expose GET /stock, GET /materiaux/{id}/mouvements et POST /mouvements.
class StockScreen extends StatefulWidget {
  const StockScreen({required this.api, required this.role, super.key});

  final ApiClient api;
  final String role;

  @override
  State<StockScreen> createState() => _StockScreenState();
}

enum _StockFiltre { tous, alertes }

class _StockScreenState extends State<StockScreen> {
  final _search = TextEditingController();
  List<Map<String, dynamic>> _lignes = [];
  bool _loading = true;
  String? _error;
  _StockFiltre _filtre = _StockFiltre.tous;

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
      final data = await widget.api.getData('stock');
      _lignes = List<Map<String, dynamic>>.from(data as List);
    } catch (error) {
      _error = error.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _filtrees {
    final terme = _search.text.trim().toLowerCase();
    return _lignes.where((ligne) {
      if (_filtre == _StockFiltre.alertes && ligne['sous_seuil'] != true) {
        return false;
      }
      if (terme.isEmpty) return true;
      return ['code', 'designation', 'unite']
          .any((champ) => '${ligne[champ] ?? ''}'.toLowerCase().contains(terme));
    }).toList();
  }

  bool get _peutEcrire => _module.canWrite(widget.role);

  @override
  Widget build(BuildContext context) {
    final lignes = _filtrees;
    final alertes = _lignes.where((l) => l['sous_seuil'] == true).length;
    final valeurTotale = _lignes.fold<double>(0, (total, ligne) => total + _nombre(ligne['stock']));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: TextField(
            controller: _search,
            textInputAction: TextInputAction.search,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Rechercher un matériau',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _Compteur(
                  valeur: '${lignes.length}',
                  libelle: alertes > 0 ? 'matériau(x), $alertes sous seuil' : 'matériau(x)',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Compteur(
                  valeur: compactNumber(valeurTotale),
                  libelle: 'unités en stock',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _FiltreChip(
                label: 'Tous',
                actif: _filtre == _StockFiltre.tous,
                onTap: () => setState(() => _filtre = _StockFiltre.tous),
              ),
              const SizedBox(width: 8),
              _FiltreChip(
                label: 'Sous seuil ($alertes)',
                alerte: true,
                actif: _filtre == _StockFiltre.alertes,
                onTap: () => setState(() => _filtre = _StockFiltre.alertes),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: _loading && _lignes.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _error != null && _lignes.isEmpty
              ? ErrorPanel(message: _error!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: lignes.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(height: MediaQuery.sizeOf(context).height * .25),
                            const Center(
                              child: Icon(
                                Icons.inventory_2_outlined,
                                size: 38,
                                color: AppColors.muted,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: Text(
                                _search.text.trim().isEmpty
                                    ? 'Aucun matériau en stock.'
                                    : 'Aucun résultat.',
                                style: const TextStyle(color: AppColors.muted),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                          itemCount: lignes.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) => _MateriauCard(
                            ligne: lignes[index],
                            peutEcrire: _peutEcrire,
                            onMouvement: ({required type}) => _ouvrirMouvement(lignes[index], type: type),
                            onHistorique: () => _historique(lignes[index]),
                          ),
                        ),
                ),
        ),
      ],
    );
  }

  Future<void> _historique(Map<String, dynamic> ligne) => Navigator.push<void>(
    context,
    MaterialPageRoute<void>(
      builder: (_) => MouvementsScreen(
        api: widget.api,
        materiau: ligne,
      ),
    ),
  );

  Future<void> _ouvrirMouvement(
    Map<String, dynamic> ligne, {
    String type = 'sortie',
  }) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => MouvementSheet(
        api: widget.api,
        materiau: ligne,
        typeInitial: type,
      ),
    );
    if (saved == true) _load();
  }
}

/// Enregistre un mouvement de stock (POST /mouvements).
class MouvementSheet extends StatefulWidget {
  const MouvementSheet({
    required this.api,
    required this.materiau,
    this.typeInitial = 'sortie',
    super.key,
  });

  final ApiClient api;
  final Map<String, dynamic> materiau;
  final String typeInitial;

  @override
  State<MouvementSheet> createState() => _MouvementSheetState();
}

class _MouvementSheetState extends State<MouvementSheet> {
  final _quantite = TextEditingController();
  final _motif = TextEditingController(text: 'Sortie manuelle');
  final _form = GlobalKey<FormState>();
  late String _type = widget.typeInitial;
  String? _chantierId;
  List<Map<String, dynamic>> _chantiers = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadChantiers();
  }

  @override
  void dispose() {
    _quantite.dispose();
    _motif.dispose();
    super.dispose();
  }

  Future<void> _loadChantiers() async {
    try {
      final data = await widget.api.getData('chantiers?limite=200');
      final rows = data is List ? data : (data as Map)['elements'] as List? ?? [];
      if (mounted) {
        setState(() => _chantiers = List<Map<String, dynamic>>.from(rows));
      }
    } catch (_) {
      // Le chantier reste facultatif : l'echec du chargement ne bloque pas la sortie.
    }
  }

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      await widget.api.post('mouvements', {
        'materiau_id': int.parse(widget.materiau['id'].toString()),
        'type': _type,
        'quantite': double.parse(_quantite.text.trim()),
        if (_chantierId != null) 'chantier_id': int.parse(_chantierId!),
        'motif': _motif.text.trim(),
      });
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

  @override
  Widget build(BuildContext context) {
    final unite = '${widget.materiau['unite'] ?? ''}';
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _form,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mouvement de stock',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.materiau['code'] ?? '—'} · ${widget.materiau['designation'] ?? 'Matériau'}',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Stock actuel : ${_formatNombre(_nombre(widget.materiau['stock']))} $unite',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 18),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'entree', label: Text('Entrée'), icon: Icon(Icons.south_west)),
                      ButtonSegment(value: 'sortie', label: Text('Sortie'), icon: Icon(Icons.north_east)),
                      ButtonSegment(value: 'ajustement', label: Text('Ajust.'), icon: Icon(Icons.tune)),
                    ],
                    selected: {_type},
                    onSelectionChanged: (value) => setState(() => _type = value.first),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _quantite,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: 'Quantité ($unite)'),
                    validator: (value) {
                      final nombre = double.tryParse(value?.trim() ?? '');
                      if (nombre == null) return 'Quantité invalide.';
                      if (nombre <= 0) return 'La quantité doit être positive.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _chantierId,
                    decoration: const InputDecoration(labelText: 'Chantier (facultatif)'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Aucun')),
                      ..._chantiers.map(
                        (row) => DropdownMenuItem(
                          value: row['id'].toString(),
                          child: Text(
                            '${row['code'] ?? ''} ${row['nom'] ?? ''}'.trim(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) => _chantierId = value,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _motif,
                    decoration: const InputDecoration(labelText: 'Motif'),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _saving ? null : () => Navigator.pop(context),
                          child: const Text('Annuler'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _saving ? null : _save,
                          child: Text(_saving ? 'Enregistrement…' : 'Valider'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Historique des mouvements d'un materiau (GET /materiaux/{id}/mouvements).
class MouvementsScreen extends StatefulWidget {
  const MouvementsScreen({required this.api, required this.materiau, super.key});

  final ApiClient api;
  final Map<String, dynamic> materiau;

  @override
  State<MouvementsScreen> createState() => _MouvementsScreenState();
}

class _MouvementsScreenState extends State<MouvementsScreen> {
  Future<List<Map<String, dynamic>>>? _future;

  @override
  void initState() {
    super.initState();
    _future = _charger();
  }

  Future<List<Map<String, dynamic>>> _charger() async {
    final data = await widget.api.getData(
      'materiaux/${widget.materiau['id']}/mouvements',
    );
    return List<Map<String, dynamic>>.from(data as List);
  }

  Future<void> _recharger() async {
    final future = _charger();
    setState(() => _future = future);
    await future;
  }

  @override
  Widget build(BuildContext context) {
    final unite = '${widget.materiau['unite'] ?? ''}';
    return Scaffold(
      appBar: AppBar(title: Text('${widget.materiau['designation'] ?? 'Matériau'}')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorPanel(message: snapshot.error.toString(), onRetry: _recharger);
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final mouvements = snapshot.data!;
          if (mouvements.isEmpty) {
            return const Center(
              child: Text(
                'Aucun mouvement enregistré.',
                style: TextStyle(color: AppColors.muted),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _recharger,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: mouvements.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final mouvement = mouvements[index];
                final type = mouvement['type']?.toString() ?? '';
                final entree = type == 'entree';
                final quantite = _nombre(mouvement['quantite']);
                final signe = entree
                    ? '+'
                    : type == 'ajustement'
                    ? '='
                    : '−';
                return ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: Icon(
                    entree ? Icons.south_west : Icons.north_east,
                    color: entree ? AppColors.forest : const Color(0xFF9C422B),
                  ),
                  title: Text(
                    '$signe${_formatNombre(quantite)} $unite',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: entree ? AppColors.forest : const Color(0xFF9C422B),
                    ),
                  ),
                  subtitle: Text(
                    [
                      labelMouvement(type),
                      formatDate(mouvement['date_mouvement']),
                      mouvement['chantier_nom'],
                      mouvement['motif'],
                    ]
                        .where(
                          (valeur) =>
                              valeur != null && valeur.toString().isNotEmpty,
                        )
                        .join(' · '),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

String labelMouvement(String type) => switch (type) {
  'entree' => 'Entrée',
  'sortie' => 'Sortie',
  'ajustement' => 'Ajustement',
  final autre => autre,
};

/// Carte materiau : niveau, seuil, part du seuil atteint et actions rapides.
class _MateriauCard extends StatelessWidget {
  const _MateriauCard({
    required this.ligne,
    required this.peutEcrire,
    required this.onMouvement,
    required this.onHistorique,
  });

  final Map<String, dynamic> ligne;
  final bool peutEcrire;
  final void Function({required String type}) onMouvement;
  final VoidCallback onHistorique;

  @override
  Widget build(BuildContext context) {
    final sousSeuil = ligne['sous_seuil'] == true;
    final stock = _nombre(ligne['stock']);
    final seuil = ligne['seuil_alerte'] == null ? null : _nombre(ligne['seuil_alerte']);
    final ratio = seuil == null || seuil <= 0 ? 1.0 : (stock / seuil).clamp(0.0, 2.0);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 10, 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: sousSeuil
            ? Border.all(color: const Color(0xFFE9C3A0))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ligne['designation']?.toString() ?? 'Matériau',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${ligne['code'] ?? 'Sans code'} · ${ligne['unite'] ?? ''}',
                      style: const TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_formatNombre(stock)} ${ligne['unite'] ?? ''}',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: sousSeuil ? const Color(0xFFAE5227) : AppColors.forest,
                    ),
                  ),
                  if (seuil != null)
                    Text(
                      'Seuil $seuil',
                      style: TextStyle(
                        fontSize: 11,
                        color: sousSeuil ? const Color(0xFFAE5227) : AppColors.muted,
                        fontWeight: sousSeuil ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                ],
              ),
              IconButton(
                onPressed: onHistorique,
                icon: const Icon(Icons.history, size: 20),
                tooltip: 'Historique',
              ),
            ],
          ),
          if (seuil != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: ratio.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: const Color(0xFFEAF0EC),
                color: sousSeuil
                    ? const Color(0xFFAE5227)
                    : ratio >= 1
                    ? AppColors.forest
                    : const Color(0xFFD5A13B),
              ),
            ),
          ],
          if (peutEcrire) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => onMouvement(type: 'sortie'),
                    icon: const Icon(Icons.north_east, size: 17),
                    label: const Text('Sortie'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => onMouvement(type: 'entree'),
                    icon: const Icon(Icons.south_west, size: 17),
                    label: const Text('Entrée'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Compteur extends StatelessWidget {
  const _Compteur({required this.valeur, required this.libelle});

  final String valeur;
  final String libelle;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          valeur,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink),
        ),
        Text(
          libelle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11, color: AppColors.muted),
        ),
      ],
    ),
  );
}

class _FiltreChip extends StatelessWidget {
  const _FiltreChip({
    required this.label,
    required this.actif,
    required this.onTap,
    this.alerte = false,
  });

  final String label;
  final bool actif;
  final bool alerte;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final couleur = alerte ? const Color(0xFFAE5227) : AppColors.forest;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: actif ? couleur : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: actif ? couleur : const Color(0xFFE2E5DC)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: actif ? Colors.white : AppColors.muted,
          ),
        ),
      ),
    );
  }
}

double _nombre(dynamic value) => double.tryParse(value?.toString() ?? '') ?? 0;

String _formatNombre(double value) => value == value.roundToDouble()
    ? value.round().toString()
    : value.toStringAsFixed(2).replaceAll('.', ',');

/// Module Stock du catalogue, reutilise pour les permissions.
final AppModule _module = appModules.firstWhere(
  (module) => module.id == 'stock',
);
