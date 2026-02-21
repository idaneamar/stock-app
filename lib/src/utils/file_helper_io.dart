import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:developer';

class FileHelper {
  static Future<bool> requestStoragePermission() async {
    if (kIsWeb) return true;

    try {
      if (Platform.isAndroid) {
        final androidVersion = await _getAndroidVersion();

        if (androidVersion >= 33) {
          return true;
        }

        if (androidVersion >= 30) {
          return await Permission.manageExternalStorage.request().isGranted;
        }

        return await Permission.storage.request().isGranted;
      }

      return true;
    } catch (e) {
      log('Error requesting storage permission: $e');
      return false;
    }
  }

  static Future<String> getDownloadsDirectory() async {
    if (kIsWeb) {
      throw UnsupportedError('Downloads directory not supported on web');
    }

    try {
      if (Platform.isAndroid) {
        final Directory? directory = await getExternalStorageDirectory();
        if (directory != null) {
          final downloadsPath = '/storage/emulated/0/Download';
          final downloadsDir = Directory(downloadsPath);
          if (await downloadsDir.exists()) {
            return downloadsPath;
          }

          return directory.path;
        }
      }

      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    } catch (e) {
      log('Error getting downloads directory: $e');

      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
  }

  static Future<String> saveFileToDownloads(
    List<int> bytes,
    String fileName,
  ) async {
    try {
      if (Platform.isAndroid) {
        // Use platform channel to save to public Downloads folder
        try {
          const platform = MethodChannel('com.stock_app/downloads');
          final result = await platform.invokeMethod('saveToDownloads', {
            'bytes': Uint8List.fromList(bytes),
            'fileName': fileName,
          });

          if (result != null) {
            log('File saved to Downloads: $result');
            return result as String;
          }
        } on PlatformException catch (e) {
          log('Platform channel error: ${e.message}');
          // Fall back to old method if platform channel fails
        }

        // Fallback for older Android versions or if platform channel fails
        final androidVersion = await _getAndroidVersion();
        if (androidVersion < 29) {
          final hasPermission = await requestStoragePermission();
          if (!hasPermission) {
            throw Exception('Storage permission denied');
          }

          final downloadsPath = await getDownloadsDirectory();
          final filePath = '$downloadsPath/$fileName';

          final file = File(filePath);
          await file.writeAsBytes(bytes);

          log('File saved to: $filePath');
          return filePath;
        }
      }

      final appDir = await getApplicationDocumentsDirectory();
      final filePath = '${appDir.path}/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(bytes);

      log('File saved to app directory: $filePath');
      return filePath;
    } catch (e) {
      log('Error saving file: $e');

      try {
        final appDir = await getApplicationDocumentsDirectory();
        final filePath = '${appDir.path}/$fileName';

        final file = File(filePath);
        await file.writeAsBytes(bytes);

        log('File saved to fallback location: $filePath');
        return filePath;
      } catch (fallbackError) {
        log('Fallback save also failed: $fallbackError');
        rethrow;
      }
    }
  }

  static Future<int> _getAndroidVersion() async {
    if (Platform.isAndroid) {
      try {
        final info = await Process.run('getprop', ['ro.build.version.sdk']);
        return int.tryParse(info.stdout.toString().trim()) ?? 30;
      } catch (e) {
        log('Error getting Android version: $e');
        return 30;
      }
    }
    return 30;
  }
}
