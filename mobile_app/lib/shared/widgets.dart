import 'package:flutter/material.dart';

import 'app_theme.dart';

class ErrorPanel extends StatelessWidget {
  const ErrorPanel({required this.message, required this.onRetry, super.key});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.cloud_off_outlined, size: 38, color: Color(0xFF9C422B)),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 14),
        OutlinedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Réessayer')),
      ]),
    ),
  );
}

class MetricTile extends StatelessWidget {
  const MetricTile({required this.label, required this.value, required this.icon, required this.tint, super.key});

  final String label;
  final String value;
  final IconData icon;
  final Color tint;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 112),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 33, height: 33, decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: AppColors.forest)),
      const SizedBox(height: 10),
      Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.ink)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
    ]),
  );
}

String formatAriary(dynamic value) {
  if (value == null) return '—';
  final amount = int.tryParse(value.toString());
  if (amount == null) return '$value Ar';
  final grouped = amount.abs().toString().replaceAllMapped(RegExp(r'(?<=\d)(?=(\d{3})+$)'), (_) => ' ');
  return '${amount < 0 ? '-' : ''}$grouped Ar';
}