import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:developer';

class DownloadsHelper {
  static const platform = MethodChannel('com.stock_app/downloads');

  /// Save file to public Downloads folder using MediaStore (Android 10+)
  static Future<String?> saveToDownloads(
    List<int> bytes,
    String fileName,
  ) async {
    if (kIsWeb) {
      throw UnsupportedError('Not supported on web');
    }

    if (!Platform.isAndroid) {
      throw UnsupportedError('Only supported on Android');
    }

    try {
      final result = await platform.invokeMethod('saveToDownloads', {
        'bytes': Uint8List.fromList(bytes),
        'fileName': fileName,
      });

      if (result != null) {
        log('File saved to Downloads: $result');
        return result as String;
      }
      return null;
    } on PlatformException catch (e) {
      log('Failed to save file: ${e.message}');
      throw Exception('Failed to save file: ${e.message}');
    }
  }
}
