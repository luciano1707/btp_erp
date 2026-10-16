import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../shared/app_theme.dart';
import '../../shared/labels.dart';
import '../../shared/widgets.dart';
import '../modules/api_module_screen.dart';
import '../modules/module_catalog.dart';

enum DocType { devis, facture }

/// Ecran Facturation : reprend `facturation/liste.php` du back-office web.
///
/// Un onglet pour les devis, un pour les factures, avec recherche,
/// filtres par statut, synthese des montants et acces a l'impression.
class BillingScreen extends StatefulWidget {
  const BillingScreen({required this.api, required this.role, super.key});

  final ApiClient api;
  final String role;

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen>
    with SingleTickerProviderStateMixin {
  late final AppModule _devis = _module('devis');
  late final AppModule _factures = _module('factures');
  late final List<DocType> _types;
  late final TabController _tabs;
  List<Map<String, dynamic>> _devisLignes = [];
  List<Map<String, dynamic>> _factureLignes = [];
  final Map<DocType, String> _recherche = {
    DocType.devis: '',
    DocType.facture: '',
  };
  final Map<DocType, String> _statut = {DocType.devis: '', DocType.facture: ''};
  bool _chargement = true;
  String? _erreur;

  static const _statutsDevis = <String, String>{
    'brouillon': 'Brouillon',
    'envoye': 'Envoyé',
    'accepte': 'Accepté',
    'refuse': 'Refusé',
    'converti': 'Converti',
  };
  static const _statutsFacture = <String, String>{
    'brouillon': 'Brouillon',
    'emise': 'Émise',
    'payee_partiel': 'Partiellement payée',
    'payee': 'Payée',
    'annulee': 'Annulée',
  };

  AppModule _module(String id) =>
      appModules.firstWhere((module) => module.id == id);

  @override
  void initState() {
    super.initState();
    _types = [
      if (_devis.canRead(widget.role)) DocType.devis,
      if (_factures.canRead(widget.role)) DocType.facture,
    ];
    _tabs = TabController(length: _types.length, vsync: this);
    _charger();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _charger() async {
    setState(() {
      _chargement = true;
      _erreur = null;
    });
    try {
      final reponses = await Future.wait([
        if (_devis.canRead(widget.role)) _liste(DocType.devis),
        if (_factures.canRead(widget.role)) _liste(DocType.facture),
      ]);
      var index = 0;
      _devisLignes = _devis.canRead(widget.role)
          ? reponses[index++]
          : [];
      _factureLignes = _factures.canRead(widget.role)
          ? reponses[index]
          : [];
    } catch (error) {
      _erreur = error.toString();
    } finally {
      if (mounted) setState(() => _chargement = false);
    }
  }

  Future<List<Map<String, dynamic>>> _liste(DocType type) async {
    final endpoint = type == DocType.devis ? 'devis' : 'factures';
    final requete = StringBuffer('?limite=100');
    final terme = _recherche[type]!.trim();
    if (terme.isNotEmpty) {
      requete.write('&recherche=${Uri.encodeQueryComponent(terme)}');
    }
    final data = await widget.api.getData('$endpoint$requete');
    return List<Map<String, dynamic>>.from((data as Map)['elements'] as List);
  }

  void _rechercher(DocType type, String valeur) {
    setState(() => _recherche[type] = valeur);
    _charger();
  }

  List<Map<String, dynamic>> _filtres(DocType type) {
    final statut = _statut[type]!;
    final source = type == DocType.devis ? _devisLignes : _factureLignes;
    if (statut.isEmpty) return source;
    return source.where((doc) => doc['statut']?.toString() == statut).toList();
  }

  double _totalTTC(DocType type) => _filtres(
    type,
  ).fold(0, (total, doc) => total + _nombre(doc['montant_ttc']));

  double _totalReste(DocType type) => _filtres(type).fold(
    0,
    (total, doc) =>
        total + (_nombre(doc['montant_ttc']) - _nombre(doc['montant_paye'])),
  );

  @override
  Widget build(BuildContext context) {
    if (_chargement && _devisLignes.isEmpty && _factureLignes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_erreur != null && _devisLignes.isEmpty && _factureLignes.isEmpty) {
      return ErrorPanel(message: _erreur!, onRetry: _charger);
    }
    if (_types.isEmpty) {
      return const Center(
        child: Text(
          'Aucun document accessible avec votre rôle.',
          style: TextStyle(color: AppColors.muted),
        ),
      );
    }
    return Column(
      children: [
        TabBar(
          controller: _tabs,
          labelColor: AppColors.forest,
          unselectedLabelColor: AppColors.muted,
          indicatorColor: AppColors.forest,
          tabs: [
            for (final type in _types)
              Tab(
                text: type == DocType.devis
                    ? 'Devis (${_devisLignes.length})'
                    : 'Factures (${_factureLignes.length})',
              ),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              for (final type in _types)
                _panneau(type, type == DocType.devis ? _devis : _factures),
            ],
          ),
        ),
      ],
    );
  }

  Widget _panneau(DocType type, AppModule module) {
    if (!module.canRead(widget.role)) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 36,
                color: AppColors.muted,
              ),
              const SizedBox(height: 12),
              Text(
                'Accès aux ${type == DocType.devis ? 'devis' : 'factures'} réservé au rôle autorisé.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted),
              ),
            ],
          ),
        ),
      );
    }
    final documents = _filtres(type);
    final statuts = type == DocType.devis ? _statutsDevis : _statutsFacture;
    final champDate = type == DocType.devis ? 'date_devis' : 'date_facture';
    final peutEcrire = module.canWrite(widget.role);

    return RefreshIndicator(
      onRefresh: _charger,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: _Somme(
                  label: 'Montant TTC',
                  valeur: formatMontant(_totalTTC(type)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Somme(
                  label: 'Reste à encaisser',
                  valeur: formatMontant(_totalReste(type)),
                  alerte: _totalReste(type) > 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            textInputAction: TextInputAction.search,
            onSubmitted: (valeur) => _rechercher(type, valeur),
            decoration: InputDecoration(
              labelText: 'Rechercher une référence ou un client',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                onPressed: () => _rechercher(type, _recherche[type]!),
                icon: const Icon(Icons.arrow_forward),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _PuceStatut(
                  label: 'Tous',
                  actif: _statut[type]!.isEmpty,
                  onTap: () => setState(() => _statut[type] = ''),
                ),
                for (final entree in statuts.entries)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _PuceStatut(
                      label: entree.value,
                      actif: _statut[type] == entree.key,
                      onTap: () => setState(() => _statut[type] = entree.key),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (documents.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Text(
                  'Aucun document.',
                  style: TextStyle(color: AppColors.muted),
                ),
              ),
            )
          else
            for (final doc in documents)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _DocumentCard(
                  document: doc,
                  champDate: champDate,
                  onTap: () => _ouvrir(module, doc),
                ),
              ),
          if (peutEcrire) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () =>
                  Navigator.push<bool>(
                    context,
                    MaterialPageRoute<bool>(
                      builder: (_) => ModuleFormScreen(
                        api: widget.api,
                        module: module,
                        role: widget.role,
                      ),
                    ),
                  ).then((cree) {
                    if (cree == true) _charger();
                  }),
              icon: const Icon(Icons.add),
              label: Text(
                type == DocType.devis ? 'Nouveau devis' : 'Nouvelle facture',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _ouvrir(AppModule module, Map<String, dynamic> doc) async {
    final modifie = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => RecordDetailScreen(
          api: widget.api,
          module: module,
          role: widget.role,
          item: doc,
        ),
      ),
    );
    if (modifie == true) _charger();
  }
}

class _Somme extends StatelessWidget {
  const _Somme({
    required this.label,
    required this.valeur,
    this.alerte = false,
  });

  final String label;
  final String valeur;
  final bool alerte;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.muted),
        ),
        const SizedBox(height: 6),
        Text(
          valeur,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: alerte ? const Color(0xFFAE5227) : AppColors.ink,
          ),
        ),
      ],
    ),
  );
}

class _PuceStatut extends StatelessWidget {
  const _PuceStatut({
    required this.label,
    required this.actif,
    required this.onTap,
  });

  final String label;
  final bool actif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: actif ? AppColors.forest : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: actif ? AppColors.forest : const Color(0xFFE2E5DC),
        ),
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

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({
    required this.document,
    required this.champDate,
    required this.onTap,
  });

  final Map<String, dynamic> document;
  final String champDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statut = document['statut']?.toString() ?? '';
    final couleur = Color(couleurStatut(statut));
    final ttc = _nombre(document['montant_ttc']);
    final paye = _nombre(document['montant_paye']);
    final reste = ttc - paye;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    document['reference']?.toString() ??
                        '#${document['id'] ?? ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
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
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              [document['client_nom'], formatDate(document[champDate])]
                  .where(
                    (valeur) => valeur != null && valeur.toString().isNotEmpty,
                  )
                  .join(' · '),
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  formatMontant(ttc),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.forest,
                  ),
                ),
                const Spacer(),
                if (reste > 0)
                  Text(
                    'Reste ${formatMontant(reste)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFAE5227),
                    ),
                  ),
              ],
            ),
            if (ttc > 0) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (paye / ttc).clamp(0.0, 1.0),
                  minHeight: 5,
                  backgroundColor: const Color(0xFFEAF0EC),
                  color: AppColors.forest,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

double _nombre(dynamic value) => double.tryParse(value?.toString() ?? '') ?? 0;
