import 'dart:typed_data';

class WebPickedFile {
  const WebPickedFile({
    required this.name,
    required this.bytes,
  });

  final String name;
  final Uint8List bytes;
}

Future<WebPickedFile?> pickFileBytesWithWebFallback() async {
  return null;
}
