import 'package:flutter/material.dart';

/// Small badge widget showing the sync status of a record
class SyncStatusBadge extends StatelessWidget {
  final String syncStatus;
  final double size;

  const SyncStatusBadge({
    super.key,
    required this.syncStatus,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, color, tooltip) = _statusConfig;

    return Tooltip(
      message: tooltip,
      child: Icon(icon, size: size, color: color),
    );
  }

  (IconData, Color, String) get _statusConfig {
    switch (syncStatus) {
      case 'synced':
        return (Icons.cloud_done, Colors.green, 'Sincronizado');
      case 'pending':
        return (Icons.cloud_upload, Colors.orange, 'Pendiente de sincronizar');
      case 'conflict':
        return (Icons.cloud_off, Colors.red, 'Error de sincronización');
      default:
        return (Icons.cloud_queue, Colors.grey, syncStatus);
    }
  }
}
