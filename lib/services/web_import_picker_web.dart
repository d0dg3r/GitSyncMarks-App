// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'web_import_picker_stub.dart';
export 'web_import_picker_stub.dart' show WebPickedFile;

Future<WebPickedFile?> pickFileBytesWithWebFallback() async {
  final input = html.FileUploadInputElement()
    ..accept = '.json,.enc,application/json,text/plain'
    ..multiple = false;
  input.click();

  await input.onChange.first;
  final file = input.files?.isNotEmpty == true ? input.files!.first : null;
  if (file == null) return null;

  final reader = html.FileReader();
  final completer = Completer<Uint8List>();

  reader.onLoad.listen((_) {
    final result = reader.result;
    if (result is ByteBuffer) {
      completer.complete(Uint8List.view(result));
    } else if (result is Uint8List) {
      completer.complete(result);
    } else {
      completer.complete(Uint8List(0));
    }
  });
  reader.onError.listen((_) {
    completer.completeError(reader.error ?? 'File read error');
  });

  reader.readAsArrayBuffer(file);
  final bytes = await completer.future;
  return WebPickedFile(name: file.name, bytes: bytes);
}
