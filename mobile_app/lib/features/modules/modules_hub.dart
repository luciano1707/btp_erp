import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/api_client.dart';
import '../../shared/app_theme.dart';
import '../profile/profile_screen.dart';
import 'api_module_screen.dart';
import 'module_catalog.dart';

class ModulesHub extends StatelessWidget {
  const ModulesHub({
    required this.api,
    required this.role,
    required this.user,
    required this.onLogout,
    required this.onSelectTab,
    super.key,
  });

  final ApiClient api;
  final String role;
  final Map<String, dynamic> user;
  final Future<void> Function() onLogout;
  final ValueChanged<int> onSelectTab;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          decoration: BoxDecoration(
            color: AppColors.forest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'DIGITAL CHANTIER',
                style: TextStyle(
                  color: AppColors.lime,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Espace de travail',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${user['prenom'] ?? ''} ${user['nom'] ?? ''}'.trim(),
                style: const TextStyle(color: Color(0xFFD3DED8)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _section(context, 'PILOTAGE', [
          _ModuleLink(
            title: 'Tableau de bord',
            icon: Icons.space_dashboard_outlined,
            onTap: () => onSelectTab(0),
          ),
          if (_moduleAllowed('chantiers'))
            _ModuleLink(
              title: 'Chantiers',
              icon: Icons.construction_outlined,
              onTap: () => onSelectTab(1),
            ),
          if (_allowed('finances'))
            _ModuleLink(
              title: 'Finances',
              icon: Icons.account_balance_wallet_outlined,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => FinanceScreen(api: api),
                ),
              ),
            ),
        ]),
        _section(context, 'EXPLOITATION', [
          if (_moduleAllowed('achats')) _moduleLink(context, 'achats'),
          if (_moduleAllowed('stock'))
            _ModuleLink(
              title: 'Stock',
              icon: Icons.inventory_2_outlined,
              onTap: () => onSelectTab(2),
            ),
        ]),
        _section(context, 'COMMERCIAL', [
          if (_moduleAllowed('devis') || _moduleAllowed('factures'))
            _ModuleLink(
              title: 'Facturation',
              icon: Icons.receipt_long_outlined,
              onTap: () => onSelectTab(3),
            ),
          if (_moduleAllowed('devis')) _moduleLink(context, 'devis'),
          if (_moduleAllowed('factures')) _moduleLink(context, 'factures'),
        ]),
        _section(context, 'DONNÉES', [
          if (_allowed('referentiels'))
            _ModuleLink(
              title: 'Référentiels',
              icon: Icons.storage_outlined,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => ReferentialHub(api: api, role: role),
                ),
              ),
            ),
          if (_moduleAllowed('journal')) _moduleLink(context, 'journal'),
          _ModuleLink(
            title: 'Mon profil',
            icon: Icons.person_outline,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) =>
                    ProfileScreen(api: api, user: user, onLogout: onLogout),
              ),
            ),
          ),
          if (role == 'directeur')
            _ModuleLink(
              title: 'Paramètres',
              icon: Icons.settings_outlined,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => SettingsScreen(api: api),
                ),
              ),
            ),
        ]),
      ],
    );
  }

  bool _allowed(String permission) =>
      role == 'directeur' ||
      switch (permission) {
        'finances' => role == 'comptable',
        'referentiels' => [
          'chef_chantier',
          'comptable',
          'magasinier',
        ].contains(role),
        _ => false,
      };

  bool _moduleAllowed(String id) => appModules
      .where((module) => module.id == id)
      .any((module) => module.canRead(role));

  Widget _moduleLink(BuildContext context, String id) {
    final module = appModules.firstWhere((item) => item.id == id);
    return _ModuleLink(
      title: module.title,
      icon: module.icon,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => ApiModuleScreen(api: api, module: module, role: role),
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title, List<Widget> links) {
    if (links.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 14, 8, 4),
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
        ),
        ...links,
        const Divider(height: 10),
      ],
    );
  }
}

/// Sommaire des referentiels, avec le nombre d'enregistrements de chaque
/// entite, comme la grille `referentiels/index.php` du back-office web.
class ReferentialHub extends StatefulWidget {
  const ReferentialHub({required this.api, required this.role, super.key});

  final ApiClient api;
  final String role;

  @override
  State<ReferentialHub> createState() => _ReferentialHubState();
}

class _ReferentialHubState extends State<ReferentialHub> {
  final Map<String, int> _compteurs = {};
  bool _chargement = true;

  @override
  void initState() {
    super.initState();
    _compter();
  }

  Future<void> _compter() async {
    setState(() => _chargement = true);
    final modules = referentialModules
        .where((module) => module.canRead(widget.role))
        .toList();
    for (final module in modules) {
      try {
        final data = await widget.api.getData('${module.endpoint}?limite=1');
        final total = data is Map ? data['total'] : null;
        if (mounted && total is int) {
          setState(() => _compteurs[module.id] = total);
        }
      } catch (_) {
        // Un compteur indisponible ne doit pas masquer le reste de la grille.
      }
    }
    if (mounted) setState(() => _chargement = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Référentiels'),
      actions: [
        IconButton(
          onPressed: _compter,
          icon: const Icon(Icons.refresh),
          tooltip: 'Actualiser les compteurs',
        ),
      ],
    ),
    body: RefreshIndicator(
      onRefresh: _compter,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Données de base de l’entreprise : employés, clients, fournisseurs, '
              'engins et matériaux.',
              style: TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ),
          for (final module in referentialModules.where(
            (module) => module.canRead(widget.role),
          ))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _CarteReferentiel(
                module: module,
                compteur: _compteurs[module.id],
                chargement: _chargement,
                onTap: () => Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => ApiModuleScreen(
                      api: widget.api,
                      module: module,
                      role: widget.role,
                    ),
                  ),
                ).then((_) => _compter()),
              ),
            ),
        ],
      ),
    ),
  );
}

class _CarteReferentiel extends StatelessWidget {
  const _CarteReferentiel({
    required this.module,
    required this.compteur,
    required this.chargement,
    required this.onTap,
  });

  final AppModule module;
  final int? compteur;
  final bool chargement;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0D8),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(module.icon, color: AppColors.forest),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  module.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  compteur == null
                      ? (chargement ? 'Comptage…' : 'Enregistrements')
                      : '$compteur enregistrement${compteur! > 1 ? 's' : ''}',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    ),
  );
}

class _ModuleLink extends StatelessWidget {
  const _ModuleLink({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    leading: Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: AppColors.forest),
    ),
    title: Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink),
    ),
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap,
  );
}

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({required this.api, super.key});

  final ApiClient api;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Suivi financier')),
    body: FutureBuilder<List<dynamic>>(
      future: Future.wait([
        api.getData('stats/mensuel'),
        api.getData('stats/tresorerie'),
        api.getData('stats/chantiers'),
      ]),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final months = List<Map<String, dynamic>>.from(
          snapshot.data![0] as List,
        );
        final cash = Map<String, dynamic>.from(snapshot.data![1] as Map);
        final chantierStats = List<Map<String, dynamic>>.from(
          snapshot.data![2] as List,
        );
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _FinanceValue(
              title: 'Encaissements',
              amount: cash['encaissements'],
            ),
            _FinanceValue(
              title: 'Décaissements',
              amount: cash['decaissements'],
            ),
            _FinanceValue(
              title: 'Solde de trésorerie',
              amount: cash['solde'],
              highlight: true,
            ),
            const SizedBox(height: 18),
            const Text(
              'Facturé et encaissé sur 6 mois',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            ...months.map(
              (month) => ListTile(
                title: Text('${month['libelle']} ${month['mois']}'.trim()),
                subtitle: Text('Facturé : ${formatMoney(month['facture'])}'),
                trailing: Text(
                  formatMoney(month['encaisse']),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Rentabilité par chantier',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            ...chantierStats.map(
              (chantier) => ListTile(
                title: Text(chantier['nom']?.toString() ?? 'Chantier'),
                subtitle: Text(
                  'Avancement : ${chantier['avancement'] ?? 0} % · Coûts : ${formatMoney(chantier['cout_total'])}',
                ),
                trailing: Text(
                  'Marge\n${formatMoney(chantier['marge'])}',
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

class _FinanceValue extends StatelessWidget {
  const _FinanceValue({
    required this.title,
    required this.amount,
    this.highlight = false,
  });

  final String title;
  final dynamic amount;
  final bool highlight;

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(title),
    trailing: Text(
      formatMoney(amount),
      style: TextStyle(
        fontWeight: FontWeight.w800,
        color: highlight ? AppColors.forest : AppColors.ink,
      ),
    ),
    tileColor: highlight ? const Color(0xFFE8F0D8) : Colors.white,
  );
}

String formatMoney(dynamic value) => '${value ?? 0} Ar';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({required this.api, super.key});

  final ApiClient api;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _keys = [
    'entreprise_nom',
    'entreprise_adresse',
    'entreprise_telephone',
    'entreprise_email',
    'entreprise_nif',
    'entreprise_stat',
  ];
  final Map<String, TextEditingController> _controllers = {};
  bool _loading = true;
  bool _saving = false;
  bool _uploadingLogo = false;
  String? _logoUrl;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await widget.api.getData('parametres') as Map;
      for (final key in _keys) {
        _logoUrl = data['logo_url']?.toString();
        _controllers[key] = TextEditingController(
          text: data[key]?.toString() ?? '',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Paramètres entreprise')),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Logo de l’entreprise',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Container(
                height: 120,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _logoUrl == null || _logoUrl!.isEmpty
                    ? const Text(
                        'Aucun logo enregistré',
                        style: TextStyle(color: AppColors.muted),
                      )
                    : Image.network(
                        _logoUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) =>
                            const Text('Aperçu indisponible'),
                      ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _uploadingLogo ? null : _chooseLogo,
                icon: _uploadingLogo
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload_outlined),
                label: Text(
                  _uploadingLogo ? 'Envoi…' : 'Choisir et téléverser le logo',
                ),
              ),
              const SizedBox(height: 20),
              for (final key in _keys)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: _controllers[key],
                    decoration: InputDecoration(
                      labelText: key
                          .replaceAll('entreprise_', '')
                          .replaceAll('_', ' '),
                    ),
                  ),
                ),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Enregistrement…' : 'Enregistrer'),
              ),
            ],
          ),
  );

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await widget.api.put('parametres', {
        for (final key in _keys) key: _controllers[key]!.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paramètres enregistrés.')),
        );
      }
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

  Future<void> _chooseLogo() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (bytes.lengthInBytes > 2 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Le logo ne doit pas dépasser 2 Mo.')),
        );
      }
      return;
    }
    setState(() => _uploadingLogo = true);
    try {
      final response =
          await widget.api.postMultipart(
                'parametres/logo',
                fieldName: 'logo',
                bytes: bytes,
                filename: file.name,
              )
              as Map;
      if (mounted) {
        setState(() => _logoUrl = response['logo_url']?.toString());
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Logo mis à jour.')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _uploadingLogo = false);
    }
  }
}
