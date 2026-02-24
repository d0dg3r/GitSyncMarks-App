import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/bookmark_node.dart';
import 'web_download_stub.dart'
    if (dart.library.html) 'web_download_web.dart';

/// Exports the bookmark tree as GitSyncMarks-compatible JSON and shares it.
class BookmarkExportService {
  /// Builds a JSON string from the bookmark tree.
  /// Format: { "version": 2, "folders": [ { "title", "children": [...] } ] }
  /// Each child is either { "title", "url" } for bookmarks or
  /// { "title", "children" } for folders.
  String buildExportJson(List<BookmarkFolder> rootFolders) {
    final folders = rootFolders.map(_folderToJson).toList();
    final data = <String, dynamic>{
      'version': 2,
      'folders': folders,
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Map<String, dynamic> _folderToJson(BookmarkFolder folder) {
    final children = folder.children.map((node) {
      return switch (node) {
        Bookmark(:final title, :final url) => {'title': title, 'url': url},
        BookmarkFolder() => _folderToJson(node),
      };
    }).toList();
    return {'title': folder.title, 'children': children};
  }

  /// Writes the export JSON to a temp file and opens the share sheet.
  Future<void> exportAndShare(List<BookmarkFolder> rootFolders) async {
    final jsonString = buildExportJson(rootFolders);
    final now = DateTime.now();
    final datePart =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final fileName = 'gitsyncmarks-bookmarks-$datePart.json';

    if (kIsWeb) {
      final webBytes = Uint8List.fromList(utf8.encode(jsonString));
      await downloadBytesForWeb(webBytes, fileName, 'application/json');
      return;
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(jsonString);

    late final bool isDesktop;
    try {
      isDesktop = Platform.isLinux || Platform.isWindows || Platform.isMacOS;
    } catch (e) {
      rethrow;
    }
    if (isDesktop) {
      final savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Bookmarks',
        fileName: fileName,
      );
      if (savePath == null) return;
      await file.copy(savePath);
    } else {
      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'GitSyncMarks Bookmarks',
      );
    }
  }
}
