import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/services/storage_service.dart';

final packageInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return await PackageInfo.fromPlatform();
});

final storageUsageProvider = FutureProvider<String>((ref) async {
  final service = StorageService();
  return await service.getStorageUsage();
});
