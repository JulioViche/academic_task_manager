import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_notifier.dart';

/// Service that reads the ambient light sensor and auto-switches theme.
/// Uses the platform light sensor via EventChannel.
class LightSensorService {
  static const EventChannel _channel = EventChannel('light_sensor_stream');

  StreamSubscription? _subscription;
  double _lastLux = -1;
  bool _isActive = false;

  bool get isActive => _isActive;
  double get lastLux => _lastLux;

  /// Start listening to the light sensor.
  /// [onLuxChanged] is called whenever a new lux reading arrives.
  void startListening({required void Function(double lux) onLuxChanged}) {
    if (_isActive) return;
    _isActive = true;
    try {
      _subscription = _channel.receiveBroadcastStream().listen(
        (event) {
          final lux = (event as num).toDouble();
          _lastLux = lux;
          onLuxChanged(lux);
        },
        onError: (error) {
          debugPrint('LightSensor error: $error');
          _isActive = false;
        },
      );
    } catch (e) {
      debugPrint('LightSensor not available: $e');
      _isActive = false;
    }
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _isActive = false;
  }

  void dispose() {
    stopListening();
  }
}

// ─── Provider ───────────────────────────────────────────

final lightSensorServiceProvider = Provider<LightSensorService>((ref) {
  final service = LightSensorService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for auto-theme mode preference
final autoThemeEnabledProvider = StateProvider<bool>((ref) => false);

/// Provider that manages the light sensor → theme integration
final lightSensorThemeProvider = Provider<void>((ref) {
  final isEnabled = ref.watch(autoThemeEnabledProvider);
  final sensor = ref.read(lightSensorServiceProvider);
  final themeNotifier = ref.read(themeProvider.notifier);

  if (isEnabled) {
    sensor.startListening(onLuxChanged: (lux) {
      if (lux < 50) {
        themeNotifier.setTheme(ThemeMode.dark);
      } else if (lux > 200) {
        themeNotifier.setTheme(ThemeMode.light);
      }
    });
  } else {
    sensor.stopListening();
  }
});
