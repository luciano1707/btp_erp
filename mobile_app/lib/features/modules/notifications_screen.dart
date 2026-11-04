import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../shared/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({required this.api, super.key});

  final ApiClient api;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  int _unread = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await widget.api.getData('notifications');
      final payload = Map<String, dynamic>.from(response as Map);
      final rows = payload['elements'] as List? ?? [];
      if (!mounted) return;
      setState(() {
        _notifications = rows
            .whereType<Map>()
            .map((row) => Map<String, dynamic>.from(row))
            .toList();
        _unread = int.tryParse(payload['non_lues']?.toString() ?? '') ?? 0;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _markAllRead() async {
    try {
      await widget.api.post('notifications/tout-lire', {});
      await _load();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Future<void> _open(Map<String, dynamic> item) async {
    if (item['lu'].toString() != '1') {
      try {
        await widget.api.post('notifications/${item['id']}/lue', {});
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
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item['titre']?.toString() ?? 'Notification'),
        content: Text(item['message']?.toString() ?? ''),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Notifications'),
      actions: [
        if (_unread > 0)
          TextButton(onPressed: _markAllRead, child: const Text('Tout lire')),
      ],
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _load,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          )
        : RefreshIndicator(
            onRefresh: _load,
            child: _notifications.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 160),
                      Icon(
                        Icons.notifications_none_outlined,
                        size: 52,
                        color: AppColors.muted,
                      ),
                      SizedBox(height: 12),
                      Center(child: Text('Aucune notification.')),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = _notifications[index];
                      final unread = item['lu'].toString() != '1';
                      return Card(
                        child: ListTile(
                          onTap: () => _open(item),
                          leading: Icon(
                            unread
                                ? Icons.notifications_active_outlined
                                : Icons.notifications_none_outlined,
                            color: unread ? AppColors.forest : AppColors.muted,
                          ),
                          title: Text(
                            item['titre']?.toString() ?? 'Notification',
                            style: TextStyle(
                              fontWeight: unread
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            item['message']?.toString() ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: unread
                              ? const CircleAvatar(
                                  radius: 4,
                                  backgroundColor: AppColors.forest,
                                )
                              : null,
                        ),
                      );
                    },
                  ),
          ),
  );
}
