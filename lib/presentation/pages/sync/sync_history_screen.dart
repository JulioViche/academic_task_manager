import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/sync_provider.dart';
import '../../providers/subject_notifier.dart';

/// Screen showing sync history and a "Sync Now" button with confirmation
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

      final history = await db.query(
        'sync_history',
        orderBy: 'started_at DESC',
        limit: 50,
      );

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
    final theme = Theme.of(context);

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
              onPressed: syncState.isSyncing ? null : _confirmAndSync,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 14, color: Colors.green.shade400),
                  const SizedBox(width: 4),
                  Text(
                    'Última: ${DateFormat('dd/MM/yyyy HH:mm').format(syncState.lastSyncTime!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  if (syncState.uploadedCount > 0 || syncState.downloadedCount > 0) ...[
                    const SizedBox(width: 8),
                    Text(
                      '↑${syncState.uploadedCount} ↓${syncState.downloadedCount}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
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
    final syncType = entry['sync_type'] as String? ?? 'upload';
    final startedAt = entry['started_at'] as int?;
    final error = entry['error_message'] as String?;

    final (icon, color) = _statusIcon(status);
    final directionIcon = syncType == 'download' ? '↓' : '↑';
    final dateStr = startedAt != null
        ? DateFormat('dd/MM HH:mm').format(
            DateTime.fromMillisecondsSinceEpoch(startedAt),
          )
        : '';

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text('$directionIcon ${_operationLabel(operation)} ${_entityLabel(entityType)}'),
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

  /// Show confirmation dialog then sync
  Future<void> _confirmAndSync() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.sync, size: 40),
        title: const Text('¿Sincronizar datos?'),
        content: const Text(
          'Se subirán los cambios locales al servidor y se descargarán '
          'los datos nuevos o actualizados.\n\n'
          'Esto puede tomar unos segundos dependiendo de tu conexión.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(ctx).pop(true),
            icon: const Icon(Icons.sync, size: 18),
            label: const Text('Sincronizar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await ref.read(syncNotifierProvider.notifier).syncNow();
    await _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '↑${result.uploaded} subidos, ↓${result.downloaded} descargados',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 4),
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
      case 'download':
        return 'Descargar';
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
      case 'grades':
        return 'calificación';
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
