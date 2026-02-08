import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/network_info.dart';

// External
final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((
  ref,
) async {
  return await SharedPreferences.getInstance();
});

// Core
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(ref.read(connectivityProvider));
});

// Repositories (Placeholders for now, implemented in Data layer)
// Use Cases (Placeholders for now)
