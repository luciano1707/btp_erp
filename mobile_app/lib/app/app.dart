import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/billing/billing_screen.dart';
import '../features/home/dashboard_screen.dart';
import '../features/modules/modules_hub.dart';
import '../features/modules/api_module_screen.dart';
import '../features/modules/module_catalog.dart';
import '../features/operations/records_screen.dart';
import '../features/stock/stock_screen.dart';
import '../shared/app_theme.dart';
import '../shared/labels.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.api, this.restoreSession = true});

  final ApiClient? api;
  final bool restoreSession;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Digital Chantier',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    home: _AppShell(api: api ?? ApiClient(), restoreSession: restoreSession),
  );
}

class _AppShell extends StatefulWidget {
  const _AppShell({required this.api, required this.restoreSession});

  final ApiClient api;
  final bool restoreSession;

  @override
  State<_AppShell> createState() => _AppShellState();
}

/// Bandeau tresorerie affiche au-dessus de l'onglet Facturation.
class _TresorerieBandeau extends StatelessWidget {
  const _TresorerieBandeau({required this.tresorerie});

  final Map<String, dynamic> tresorerie;

  @override
  Widget build(BuildContext context) {
    final solde = _nombre(tresorerie['solde']);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Tuile(
              label: 'Encaissements',
              valeur: formatMontant(tresorerie['encaissements']),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _Tuile(
              label: 'Décaissements',
              valeur: formatMontant(tresorerie['decaissements']),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _Tuile(
              label: 'Solde',
              valeur: formatMontant(solde),
              alerte: solde < 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tuile extends StatelessWidget {
  const _Tuile({
    required this.label,
    required this.valeur,
    this.alerte = false,
  });

  final String label;
  final String valeur;
  final bool alerte;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 10, color: AppColors.muted)),
      const SizedBox(height: 4),
      Text(
        valeur,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: alerte ? const Color(0xFFAE5227) : AppColors.ink,
        ),
      ),
    ],
  );
}

double _nombre(dynamic value) => double.tryParse(value?.toString() ?? '') ?? 0;

class _AppShellState extends State<_AppShell> {
  Map<String, dynamic>? _user;
  Map<String, dynamic>? _dashboard;
  List<Map<String, dynamic>> _chantierStats = [];
  List<Map<String, dynamic>> _monthlyStats = [];
  List<Map<String, dynamic>> _chantiers = [];
  List<Map<String, dynamic>> _stock = [];
  Map<String, dynamic>? _tresorerie;
  String? _loadError;
  bool _restoring = true;
  bool _busy = false;
  int _tab = 0;

  static const _tabStock = 2;
  static const _tabModules = 4;

  String get _role => _user?['role']?.toString() ?? '';

  bool _canRead(String moduleId) => appModules
      .where((module) => module.id == moduleId)
      .any((module) => module.canRead(_role));

  bool get _canReadBilling => _canRead('devis') || _canRead('factures');

  @override
  void initState() {
    super.initState();
    if (widget.restoreSession) {
      _restore();
    } else {
      _restoring = false;
    }
  }

  Future<void> _restore() async {
    try {
      final user = await widget.api.restoreSession();
      if (mounted && user != null) {
        setState(() => _user = user);
        await _loadTab(0);
      }
    } catch (_) {
      await widget.api.clearSession();
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }

  Future<void> _login(String email, String password) async {
    setState(() => _busy = true);
    try {
      final user = await widget.api.login(email, password);
      if (!mounted) return;
      setState(() {
        _user = user;
        _busy = false;
      });
      await _loadTab(0);
    } on ApiException catch (error) {
      if (mounted) setState(() => _busy = false);
      _showMessage(error.message);
    } catch (_) {
      if (mounted) setState(() => _busy = false);
      _showMessage(
        'Connexion impossible. Vérifiez le réseau et l’adresse de l’API.',
      );
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Se déconnecter'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
    if (confirmed == true) await _logout();
  }

  Future<void> _logout() async {
    Navigator.of(context).popUntil((route) => route.isFirst);
    try {
      await widget.api.logout();
    } catch (_) {
      await widget.api.clearSession();
    }
    if (!mounted) return;
    setState(() {
      _user = null;
      _dashboard = null;
      _chantierStats = [];
      _monthlyStats = [];
      _chantiers = [];
      _stock = [];
      _tresorerie = null;
      _tab = 0;
    });
  }

  Future<void> _loadTab(int tab) async {
    if (tab == _tabModules) return;
    setState(() {
      _busy = true;
      _loadError = null;
    });
    try {
      if (tab == 0) {
        final canViewFinances = _role == 'directeur' || _role == 'comptable';
        final responses = await Future.wait([
          widget.api.getData('stats/tableau-de-bord'),
          widget.api.getData('stats/chantiers'),
          if (canViewFinances) widget.api.getData('stats/mensuel'),
          widget.api.getData('stock'),
        ]);
        _dashboard = Map<String, dynamic>.from(responses[0] as Map);
        _chantierStats = List<Map<String, dynamic>>.from(responses[1] as List);
        _monthlyStats = canViewFinances
            ? List<Map<String, dynamic>>.from(responses[2] as List)
            : [];
        _stock = List<Map<String, dynamic>>.from(
          responses[canViewFinances ? 3 : 2] as List,
        );
      } else if (tab == 1) {
        final response = await widget.api.getData('chantiers?limite=50') as Map;
        _chantiers = List<Map<String, dynamic>>.from(
          response['elements'] as List,
        );
      } else if (tab == _tabStock) {
        _stock = List<Map<String, dynamic>>.from(
          await widget.api.getData('stock') as List,
        );
      } else {
        // Onglet Facturation : alimente aussi les compteurs du tableau de bord.
        await _loadFacturation();
      }
    } on ApiException catch (error) {
      _loadError = error.message;
    } catch (_) {
      _loadError = 'Impossible de charger ces données.';
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _loadFacturation() async {
    final role = _role;
    final requetes = <Future<dynamic>>[
      if (role == 'directeur' || role == 'comptable')
        widget.api.getData('stats/tresorerie'),
    ];
    if (requetes.isEmpty) return;
    final reponses = await Future.wait(requetes);
    _tresorerie = Map<String, dynamic>.from(reponses.first as Map);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _selectTab(int tab) {
    if (tab == 3 && !_canReadBilling) return;
    setState(() => _tab = tab);
    if (tab != _tabModules) _loadTab(tab);
  }

  void _openModule(String moduleId) {
    final module = appModules.where((item) => item.id == moduleId).firstOrNull;
    if (module == null || !module.canRead(_role)) return;
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) =>
            ApiModuleScreen(api: widget.api, module: module, role: _role),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_restoring) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_user == null) {
      return LoginScreen(
        busy: _busy,
        onLogin: _login,
        onForgotPassword: () => Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (_) => ForgotPasswordScreen(api: widget.api),
          ),
        ),
      );
    }

    const titles = [
      'Vue d’ensemble',
      'Chantiers',
      'Stock',
      'Facturation',
      'Modules',
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[_tab],
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Se déconnecter',
            onPressed: _confirmLogout,
            icon: const Icon(Icons.logout),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.forest,
              child: Text(
                _user!['prenom']?.toString().isNotEmpty == true
                    ? _user!['prenom'].toString()[0].toUpperCase()
                    : 'D',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: [
          DashboardScreen(
            user: _user!,
            data: _dashboard,
            canViewFinances: _role == 'directeur' || _role == 'comptable',
            canReadDevis: _canRead('devis'),
            chantierStats: _chantierStats,
            monthlyStats: _monthlyStats,
            stock: _stock,
            loading: _busy,
            error: _loadError,
            onRefresh: () => _loadTab(0),
            onRetry: () => _loadTab(0),
            onOpenTab: _selectTab,
            onOpenModule: _openModule,
          ),
          RecordsScreen(
            kind: RecordKind.chantiers,
            items: _chantiers,
            loading: _busy,
            error: _loadError,
            onRefresh: () => _loadTab(1),
            onOpenChantier: (chantier) {
              final id = int.tryParse(chantier['id']?.toString() ?? '');
              if (id == null) return;
              Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => RecordDetailScreen(
                    api: widget.api,
                    module: appModules.firstWhere(
                      (item) => item.id == 'chantiers',
                    ),
                    item: chantier,
                    role: _role,
                  ),
                ),
              );
            },
          ),
          StockScreen(api: widget.api, role: _role),
          Column(
            children: [
              if (_tresorerie != null)
                _TresorerieBandeau(tresorerie: _tresorerie!),
              Expanded(
                child: BillingScreen(api: widget.api, role: _role),
              ),
            ],
          ),
          ModulesHub(
            api: widget.api,
            role: _role,
            user: _user!,
            onLogout: _logout,
            onSelectTab: _selectTab,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (tab) {
          if (tab != 3 || _canReadBilling) {
            _selectTab(tab);
          }
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.space_dashboard_outlined),
            selectedIcon: Icon(Icons.space_dashboard),
            label: 'Accueil',
          ),
          const NavigationDestination(
            icon: Icon(Icons.construction_outlined),
            selectedIcon: Icon(Icons.construction),
            label: 'Chantiers',
          ),
          const NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Stock',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Facturation',
            enabled: _canReadBilling,
          ),
          const NavigationDestination(
            icon: Icon(Icons.apps_outlined),
            selectedIcon: Icon(Icons.apps),
            label: 'Modules',
          ),
        ],
      ),
    );
  }
}
