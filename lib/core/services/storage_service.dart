import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StorageService {
  Future<String> getStorageUsage() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      int totalSize = 0;
      try {
        if (await directory.exists()) {
          directory.listSync(recursive: true, followLinks: false).forEach((
            FileSystemEntity entity,
          ) {
            if (entity is File) {
              totalSize += entity.lengthSync();
            }
          });
        }
      } catch (e) {
        // Handle permission errors or busy files
      }
      return _formatBytes(totalSize);
    } catch (e) {
      return 'Unknown';
    }
  }

  String _formatBytes(int bytes, [int decimals = 2]) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    // var i = (bytes.toString().length - 1) ~/ 3; // Log10 approximation
    // Better logic:
    // log(bytes) / log(1024)
    // But simple loop is fine.
    // Let's use standard implementation
    if (bytes < 1024) return "$bytes B";
    double num = bytes.toDouble();
    int suffixIndex = 0;
    while (num >= 1024 && suffixIndex < suffixes.length - 1) {
      num /= 1024;
      suffixIndex++;
    }
    return "${num.toStringAsFixed(decimals)} ${suffixes[suffixIndex]}";
  }
}
