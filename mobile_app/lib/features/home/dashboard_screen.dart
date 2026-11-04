import 'package:flutter/material.dart';

import '../../shared/app_theme.dart';
import '../../shared/charts.dart';
import '../../shared/labels.dart';
import '../../shared/widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    required this.user,
    required this.data,
    required this.canViewFinances,
    required this.canReadDevis,
    required this.chantierStats,
    required this.monthlyStats,
    required this.stock,
    required this.loading,
    required this.error,
    required this.onRefresh,
    required this.onRetry,
    required this.onOpenTab,
    required this.onOpenModule,
    super.key,
  });

  final Map<String, dynamic> user;
  final Map<String, dynamic>? data;
  final bool canViewFinances;
  final bool canReadDevis;
  final List<Map<String, dynamic>> chantierStats;
  final List<Map<String, dynamic>> monthlyStats;
  final List<Map<String, dynamic>> stock;
  final bool loading;
  final String? error;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;
  final ValueChanged<int> onOpenTab;
  final ValueChanged<String> onOpenModule;

  @override
  Widget build(BuildContext context) {
    if (loading && data == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null && data == null) {
      return ErrorPanel(message: error!, onRetry: onRetry);
    }
    final stats = data ?? {};
    final firstName = user['prenom']?.toString() ?? '';
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.forest,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SUIVI DE VOS OPÉRATIONS',
                  style: TextStyle(
                    color: AppColors.lime,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Bonjour${firstName.isEmpty ? '' : ', $firstName'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Voici la situation de votre activité.',
                  style: TextStyle(color: Color(0xFFDCEEFF), fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _SectionTitle('Indicateurs clés'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: MetricTile(
                  label: 'Chantiers actifs',
                  value:
                      '${stats['chantiers_actifs'] ?? '—'} / ${stats['chantiers_total'] ?? '—'}',
                  icon: Icons.construction,
                  tint: AppColors.lime,
                ),
              ),
              const SizedBox(width: 12),
              if (canViewFinances) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: MetricTile(
                    label: 'Factures impayées',
                    value: '${stats['factures_impayees'] ?? '—'}',
                    icon: Icons.receipt_long_outlined,
                    tint: const Color(0xFFFFE9D6),
                  ),
                ),
              ],
            ],
          ),
          if (canViewFinances) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _CompactMetric(
                    label: 'CA facturé',
                    value: stats['ca_facture'],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CompactMetric(
                    label: 'CA encaissé',
                    value: stats['encaisse'],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _CompactMetric(
                    label: 'Reste à encaisser',
                    value: stats['reste_a_encaisser'],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CompactMetric(
                    label: 'Marge brute',
                    value: stats['marge_brute'],
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 22),
          if (canViewFinances)
            _DashboardSection(
              title: 'Facturé et encaissé',
              subtitle: 'Six derniers mois · en Ariary',
              trailing: TextButton(
                onPressed: () => onOpenTab(3),
                child: const Text('Finances'),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ChartLegend(
                    series: [
                      ChartSeries(
                        name: 'Facturé',
                        color: chartColor(0),
                        values: const [],
                      ),
                      ChartSeries(
                        name: 'Encaissé',
                        color: chartColor(1),
                        values: const [],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  AreaChart(
                    labels: monthlyStats
                        .map((item) => item['libelle']?.toString() ?? '')
                        .toList(),
                    valueFormatter: (valeur) => formatMontant(valeur.round()),
                    series: [
                      ChartSeries(
                        name: 'Facturé',
                        color: chartColor(0),
                        values: monthlyStats
                            .map((item) => _asDouble(item['facture']))
                            .toList(),
                      ),
                      ChartSeries(
                        name: 'Encaissé',
                        color: chartColor(1),
                        values: monthlyStats
                            .map((item) => _asDouble(item['encaisse']))
                            .toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: 14),
          _DashboardSection(
            title: 'Avancement des chantiers',
            subtitle: 'Taux d’avancement moyen par chantier',
            trailing: TextButton(
              onPressed: () => onOpenTab(1),
              child: const Text('Tout voir'),
            ),
            child: chantierStats.isEmpty
                ? const Text(
                    'Aucun chantier à afficher.',
                    style: TextStyle(color: AppColors.muted),
                  )
                : Column(
                    children: chantierStats
                        .take(6)
                        .map(
                          (item) => _ProgressRow(
                            item: item,
                            onTap: () => onOpenTab(1),
                          ),
                        )
                        .toList(),
                  ),
          ),
          const SizedBox(height: 14),
          if (canViewFinances)
            _DashboardSection(
              title: 'CA facturé par chantier',
              subtitle: 'Répartition du chiffre d’affaires',
              child: DonutChart(
                segments: chantierStats
                    .map(
                      (item) => DonutSegment(
                        name: item['nom']?.toString() ?? 'Chantier',
                        value: _asDouble(item['facture']),
                      ),
                    )
                    .toList(),
                centerSubLabel: 'CA total',
                valueFormatter: (valeur) => formatMontant(valeur.round()),
              ),
            ),
          const SizedBox(height: 14),
          if (canViewFinances)
            _DashboardSection(
              title: 'Rentabilité par chantier',
              subtitle: 'Marge brute après coûts engagés',
              trailing: TextButton(
                onPressed: () => onOpenTab(3),
                child: const Text('Finances'),
              ),
              child: chantierStats.isEmpty
                  ? const Text(
                      'Aucune donnée de rentabilité.',
                      style: TextStyle(color: AppColors.muted),
                    )
                  : Column(
                      children: chantierStats.take(6).map((item) {
                        final marge = _asDouble(item['marge']);
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            item['nom']?.toString() ?? 'Chantier',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                          subtitle: Text(
                            'Coûts ${formatMontant(item['cout_total'])} · '
                            '${item['avancement'] ?? 0} % d’avancement',
                            style: const TextStyle(fontSize: 11),
                          ),
                          trailing: Text(
                            formatMontant(marge),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: marge >= 0
                                  ? AppColors.forest
                                  : const Color(0xFF9C422B),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          const SizedBox(height: 14),
          _DashboardSection(
            title: 'État du stock',
            subtitle: 'Matériaux au plus près du seuil',
            trailing: TextButton(
              onPressed: () => onOpenTab(2),
              child: const Text('Ouvrir'),
            ),
            child: _StockPreview(stock: stock, onOpenTab: onOpenTab),
          ),
          const SizedBox(height: 14),
          _DashboardSection(
            title: 'Alertes',
            child: _AlertsList(
              stats: stats,
              stock: stock,
              canViewFinances: canViewFinances,
              canReadDevis: canReadDevis,
              onOpenModule: onOpenModule,
              onOpenTab: onOpenTab,
            ),
          ),
        ],
      ),
    );
  }
}

/// Les matériaux sous seuil, avec le niveau atteint, comme sur le tableau de bord web.
class _StockPreview extends StatelessWidget {
  const _StockPreview({required this.stock, required this.onOpenTab});

  final List<Map<String, dynamic>> stock;
  final ValueChanged<int> onOpenTab;

  @override
  Widget build(BuildContext context) {
    if (stock.isEmpty) {
      return const Text(
        'Aucun matériau en stock.',
        style: TextStyle(color: AppColors.muted),
      );
    }
    final sousSeuil = stock
        .where((item) => item['sous_seuil'] == true)
        .toList();
    final sansSeuil =
        stock
            .where(
              (item) =>
                  item['sous_seuil'] != true && item['seuil_alerte'] != null,
            )
            .toList()
          ..sort((a, b) => _ratio(a).compareTo(_ratio(b)));
    final lignes = [...sousSeuil, ...sansSeuil].take(5).toList();

    return Column(
      children: [
        for (final item in lignes)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => onOpenTab(2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item['designation']?.toString() ?? 'Matériau',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  Text(
                    '${item['stock'] ?? 0} ${item['unite'] ?? ''}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: item['sous_seuil'] == true
                          ? const Color(0xFFAE5227)
                          : AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  static double _ratio(Map<String, dynamic> item) {
    final seuil = _asDouble(item['seuil_alerte']);
    if (seuil <= 0) return 999;
    return _asDouble(item['stock']) / seuil;
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w800,
      color: AppColors.ink,
    ),
  );
}

class _CompactMetric extends StatelessWidget {
  const _CompactMetric({required this.label, required this.value});
  final String label;
  final dynamic value;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 78),
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
          style: const TextStyle(color: AppColors.muted, fontSize: 11),
        ),
        const SizedBox(height: 7),
        Text(
          formatAriary(value),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
      ],
    ),
  );
}

class _DashboardSection extends StatelessWidget {
  const _DashboardSection({
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Text(
              subtitle!,
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    ),
  );
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.item, required this.onTap});

  final Map<String, dynamic> item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progress = (_asDouble(item['avancement']) / 100).clamp(0.0, 1.0);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item['nom']?.toString() ?? 'Chantier',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                Text(
                  '${(progress * 100).round()} %',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.forest,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              borderRadius: BorderRadius.circular(8),
              backgroundColor: const Color(0xFFEAF0EC),
              color: progress >= .8
                  ? const Color(0xFF26966B)
                  : const Color(0xFF367BA8),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertsList extends StatelessWidget {
  const _AlertsList({
    required this.stats,
    required this.stock,
    required this.canViewFinances,
    required this.canReadDevis,
    required this.onOpenModule,
    required this.onOpenTab,
  });

  final Map<String, dynamic> stats;
  final List<Map<String, dynamic>> stock;
  final bool canViewFinances;
  final bool canReadDevis;
  final ValueChanged<String> onOpenModule;
  final ValueChanged<int> onOpenTab;

  @override
  Widget build(BuildContext context) {
    final lowStock = stock.where((item) => item['sous_seuil'] == true).toList();
    final alerts = <Widget>[];
    if (canViewFinances && _asDouble(stats['factures_impayees']) > 0) {
      alerts.add(
        _AlertRow(
          icon: Icons.receipt_long_outlined,
          title: '${stats['factures_impayees']} facture(s) impayée(s)',
          detail: 'À relancer auprès des clients.',
          onTap: () => onOpenModule('factures'),
        ),
      );
    }
    if (canReadDevis && _asDouble(stats['devis_en_attente']) > 0) {
      alerts.add(
        _AlertRow(
          icon: Icons.request_quote_outlined,
          title: '${stats['devis_en_attente']} devis en attente',
          detail: 'Brouillons ou devis envoyés non traités.',
          onTap: () => onOpenModule('devis'),
        ),
      );
    }
    for (final item in lowStock.take(3)) {
      alerts.add(
        _AlertRow(
          icon: Icons.warning_amber_rounded,
          title: 'Stock bas · ${item['designation'] ?? 'Matériau'}',
          detail:
              'Reste ${item['stock'] ?? 0} ${item['unite'] ?? ''} (seuil : ${item['seuil_alerte'] ?? 0}).',
          onTap: () => onOpenTab(2),
        ),
      );
    }
    if (canViewFinances && _asDouble(stats['reste_a_encaisser']) > 0) {
      alerts.add(
        _AlertRow(
          icon: Icons.payments_outlined,
          title: 'Reste à encaisser',
          detail: formatAriary(stats['reste_a_encaisser']),
          onTap: () => onOpenModule('factures'),
        ),
      );
    }
    if (alerts.isEmpty) {
      return const Text(
        'Aucune alerte pour le moment.',
        style: TextStyle(color: AppColors.muted),
      );
    }
    return Column(children: alerts);
  }
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({
    required this.icon,
    required this.title,
    required this.detail,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon, color: const Color(0xFFB44A21)),
    title: Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
    ),
    subtitle: Text(detail, style: const TextStyle(fontSize: 12)),
    onTap: onTap,
  );
}

double _asDouble(dynamic value) =>
    double.tryParse(value?.toString() ?? '') ?? 0;
