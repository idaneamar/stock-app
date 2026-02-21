import 'dart:developer';
import 'dart:typed_data';
import 'package:universal_html/html.dart' as html;

class FileHelper {
  static Future<bool> requestStoragePermission() async => true;

  static Future<String> getDownloadsDirectory() async {
    throw UnsupportedError('Downloads directory not supported on web');
  }

  static Future<String> saveFileToDownloads(
    List<int> bytes,
    String fileName,
  ) async {
    try {
      final blob = html.Blob(<Object>[Uint8List.fromList(bytes)]);
      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor =
          html.AnchorElement(href: url)..setAttribute('download', fileName);
      html.document.body?.append(anchor);
      anchor.click();
      anchor.remove();
      html.Url.revokeObjectUrl(url);

      log('Triggered browser download: $fileName');
      return fileName;
    } catch (e) {
      log('Error saving file on web: $e');
      rethrow;
    }
  }
}
