import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/sync_provider.dart';
import '../../providers/subject_notifier.dart';

/// Screen showing sync history and a "Sync Now" button
class SyncHistoryScreen extends ConsumerStatefulWidget {
  const SyncHistoryScreen({super.key});

  @override
  ConsumerState<SyncHistoryScreen> createState() => _SyncHistoryScreenState();
}

class _SyncHistoryScreenState extends ConsumerState<SyncHistoryScreen> {
  List<Map<String, dynamic>> _history = [];
  int _pendingCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final db = await ref.read(databaseHelperProvider).database;

      // Get sync history
      final history = await db.query(
        'sync_history',
        orderBy: 'started_at DESC',
        limit: 50,
      );

      // Get pending count
      final pending = await ref.read(syncServiceProvider).getPendingCount();

      setState(() {
        _history = history;
        _pendingCount = pending;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final syncState = ref.watch(syncNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sincronización'),
        actions: [
          if (_pendingCount > 0)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_pendingCount pendientes',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Sync Now button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: syncState.isSyncing ? null : _syncNow,
              icon: syncState.isSyncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync),
              label: Text(
                syncState.isSyncing ? 'Sincronizando...' : 'Sincronizar ahora',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          if (syncState.lastSyncTime != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Última sincronización: ${DateFormat('dd/MM/yyyy HH:mm').format(syncState.lastSyncTime!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ),

          const Divider(),

          // History list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _history.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.history, size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text(
                              'No hay historial de sincronización',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          itemCount: _history.length,
                          itemBuilder: (context, index) =>
                              _buildHistoryTile(_history[index]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTile(Map<String, dynamic> entry) {
    final status = entry['status'] as String? ?? 'unknown';
    final entityType = entry['entity_type'] as String? ?? '';
    final operation = entry['operation'] as String? ?? '';
    final startedAt = entry['started_at'] as int?;
    final error = entry['error_message'] as String?;

    final (icon, color) = _statusIcon(status);
    final dateStr = startedAt != null
        ? DateFormat('dd/MM HH:mm').format(
            DateTime.fromMillisecondsSinceEpoch(startedAt),
          )
        : '';

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text('${_operationLabel(operation)} ${_entityLabel(entityType)}'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dateStr),
          if (error != null)
            Text(
              error,
              style: const TextStyle(color: Colors.red, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      trailing: _StatusChip(status: status),
      dense: true,
    );
  }

  Future<void> _syncNow() async {
    await ref.read(syncNotifierProvider.notifier).syncNow();
    await _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sincronización completada'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  (IconData, Color) _statusIcon(String status) {
    switch (status) {
      case 'completed':
        return (Icons.check_circle, Colors.green);
      case 'failed':
        return (Icons.error, Colors.red);
      case 'in_progress':
        return (Icons.sync, Colors.blue);
      case 'pending':
        return (Icons.hourglass_empty, Colors.orange);
      default:
        return (Icons.help_outline, Colors.grey);
    }
  }

  String _operationLabel(String op) {
    switch (op) {
      case 'create':
        return 'Crear';
      case 'update':
        return 'Actualizar';
      case 'delete':
        return 'Eliminar';
      default:
        return op;
    }
  }

  String _entityLabel(String entity) {
    switch (entity) {
      case 'subjects':
        return 'materia';
      case 'tasks':
        return 'tarea';
      case 'attachments':
        return 'adjunto';
      default:
        return entity;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'completed' => Colors.green,
      'failed' => Colors.red,
      'pending' => Colors.orange,
      _ => Colors.grey,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
