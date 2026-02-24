import 'dart:typed_data';

Future<void> downloadBytesForWeb(
  Uint8List bytes,
  String fileName,
  String mimeType,
) async {
  throw UnsupportedError('Web download helper is only available on web.');
}
