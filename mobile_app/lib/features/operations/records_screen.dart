import 'package:flutter/material.dart';

import '../../shared/app_theme.dart';
import '../../shared/widgets.dart';

enum RecordKind { chantiers, stock }

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({
    required this.kind,
    required this.items,
    required this.loading,
    required this.error,
    required this.onRefresh,
    this.onOpenChantier,
    super.key,
  });

  final RecordKind kind;
  final List<Map<String, dynamic>> items;
  final bool loading;
  final String? error;
  final Future<void> Function() onRefresh;
  final ValueChanged<Map<String, dynamic>>? onOpenChantier;

  @override
  Widget build(BuildContext context) {
    if (loading && items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null && items.isEmpty) {
      return ErrorPanel(message: error!, onRetry: onRefresh);
    }
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.27),
            const Icon(Icons.inbox_outlined, size: 38, color: AppColors.muted),
            const SizedBox(height: 12),
            Center(
              child: Text(
                kind == RecordKind.chantiers
                    ? 'Aucun chantier à afficher.'
                    : 'Aucun matériau en stock.',
                style: const TextStyle(color: AppColors.muted),
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 9),
        itemBuilder: (context, index) => kind == RecordKind.chantiers
            ? _ChantierTile(
                item: items[index],
                onTap: onOpenChantier == null
                    ? null
                    : () => onOpenChantier!(items[index]),
              )
            : _StockTile(item: items[index]),
      ),
    );
  }
}

class _ChantierTile extends StatelessWidget {
  const _ChantierTile({required this.item, this.onTap});
  final Map<String, dynamic> item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final status = item['statut']?.toString() ?? 'inconnu';
    final details = [item['localisation'], item['client_nom']]
        .where((value) => value != null && value.toString().isNotEmpty)
        .join(' · ');
    return _RecordTile(
      icon: Icons.apartment_outlined,
      title: item['nom']?.toString() ?? 'Chantier',
      subtitle: details,
      trailing: _StatusLabel(status: status),
      onTap: onTap,
    );
  }
}

class _StockTile extends StatelessWidget {
  const _StockTile({required this.item});
  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final underThreshold = item['sous_seuil'] == true;
    return _RecordTile(
      icon: underThreshold
          ? Icons.warning_amber_rounded
          : Icons.inventory_2_outlined,
      title: item['designation']?.toString() ?? 'Matériau',
      subtitle:
          '${item['code'] ?? 'Sans code'} · Seuil : ${item['seuil_alerte'] ?? '—'} ${item['unite'] ?? ''}',
      trailing: Text(
        '${item['stock'] ?? 0} ${item['unite'] ?? ''}',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: underThreshold ? const Color(0xFFAE5227) : AppColors.forest,
        ),
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.lime,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.forest),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF728078),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    ),
  );
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final active = status == 'en_cours';
    final label = switch (status) {
      'en_cours' => 'En cours',
      'planifie' => 'Planifié',
      'suspendu' => 'Suspendu',
      'termine' => 'Terminé',
      'annule' => 'Annulé',
      _ => status,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: active ? AppColors.lime : const Color(0xFFF0F3F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: active ? AppColors.forest : AppColors.muted,
        ),
      ),
    );
  }
}
