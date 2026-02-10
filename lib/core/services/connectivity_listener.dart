import 'dart:async';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'sync_service.dart';

/// Listens for connectivity changes and triggers sync when network returns
class ConnectivityListener {
  final SyncService syncService;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _wasOffline = false;

  ConnectivityListener({required this.syncService});

  /// Start listening for connectivity changes
  void startListening() {
    _subscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );
    log('ConnectivityListener: Started listening for network changes');
  }

  /// Handle connectivity changes
  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final isOnline = results.any(
      (r) => r != ConnectivityResult.none,
    );

    if (isOnline && _wasOffline) {
      log('ConnectivityListener: Network restored! Triggering sync...');
      _triggerSync();
    }

    _wasOffline = !isOnline;

    if (!isOnline) {
      log('ConnectivityListener: Device went offline');
    }
  }

  /// Trigger sync when network comes back
  Future<void> _triggerSync() async {
    try {
      // Small delay to let network stabilize
      await Future.delayed(const Duration(seconds: 2));
      
      // Process the queue first
      final count = await syncService.processQueue();
      log('ConnectivityListener: Auto-sync completed. $count operations processed.');

      // Then sync any pending records not in the queue
      await syncService.syncPendingRecords();
    } catch (e) {
      log('ConnectivityListener: Auto-sync error: $e');
    }
  }

  /// Stop listening for connectivity changes
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    log('ConnectivityListener: Stopped listening');
  }

  /// Dispose resources
  void dispose() {
    stopListening();
  }
}
