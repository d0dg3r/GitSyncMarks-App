// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:typed_data';
import 'dart:html' as html;

Future<void> downloadBytesForWeb(
  Uint8List bytes,
  String fileName,
  String mimeType,
) async {
  final blob = html.Blob(<dynamic>[bytes], mimeType);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..style.display = 'none';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
}
