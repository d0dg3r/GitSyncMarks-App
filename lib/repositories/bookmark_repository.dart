import 'dart:convert';

import '../config/github_credentials.dart';
import '../models/bookmark_node.dart';
import '../services/github_api.dart';
import '../utils/bookmark_filename.dart';

/// Orchestrates syncing bookmarks from GitHub and parsing the tree.
class BookmarkRepository {
  BookmarkRepository();

  /// Fetches the full bookmark tree from GitHub.
  /// Returns a list of root folders (toolbar, other, menu, mobile).
  Future<List<BookmarkFolder>> fetchBookmarks(GithubCredentials creds) async {
    final api = GithubApi(
      token: creds.token,
      owner: creds.owner,
      repo: creds.repo,
      branch: creds.branch,
      basePath: creds.basePath,
    );
    try {
      return await _fetchRootFolders(api, creds.basePath);
    } finally {
      api.close();
    }
  }

  /// Adds a bookmark to a folder in the repo.
  /// [folderPath] is e.g. "bookmarks/toolbar" (basePath/folderName).
  /// Returns true on success.
  Future<bool> addBookmarkToFolder(
    GithubCredentials creds,
    String folderPath,
    String title,
    String url,
  ) async {
    final api = GithubApi(
      token: creds.token,
      owner: creds.owner,
      repo: creds.repo,
      branch: creds.branch,
      basePath: creds.basePath,
    );
    try {
      final filename = bookmarkFilename(title, url);
      final content = json.encode({'title': title, 'url': url});

      final filePath = '$folderPath/$filename';
      await api.createOrUpdateFile(
        filePath,
        content,
        'Add bookmark: $title',
      );

      final orderPath = '$folderPath/_order.json';
      String? orderJson;
      String? orderSha;
      try {
        orderJson = await api.getFileContent(orderPath);
        final meta = await api.getFileMeta(orderPath);
        orderSha = meta?.sha;
      } catch (_) {}

      final List<dynamic> orderList;
      if (orderJson != null && orderJson.trim().isNotEmpty) {
        final decoded = json.decode(orderJson);
        orderList = decoded is List ? List.from(decoded) : [];
      } else {
        orderList = [];
      }

      if (!orderList.contains(filename)) {
        orderList.insert(0, filename);
        final newOrderJson = const JsonEncoder.withIndent('  ').convert(orderList);
        await api.createOrUpdateFile(
          orderPath,
          newOrderJson,
          'Update order: add $filename',
          sha: orderSha,
        );
      }

      return true;
    } finally {
      api.close();
    }
  }

  /// Moves a bookmark from one folder to another in the repo.
  /// [fromFolderPath] and [toFolderPath] are e.g. "bookmarks/toolbar" (basePath/folderName).
  /// Returns true on success.
  Future<bool> moveBookmarkToFolder(
    GithubCredentials creds,
    String fromFolderPath,
    String toFolderPath,
    Bookmark bookmark,
  ) async {
    final api = GithubApi(
      token: creds.token,
      owner: creds.owner,
      repo: creds.repo,
      branch: creds.branch,
      basePath: creds.basePath,
    );
    try {
      final sourceFilename = bookmark.filename ?? bookmarkFilename(bookmark.title, bookmark.url);
      final fromFilePath = '$fromFolderPath/$sourceFilename';

      if (fromFolderPath == toFolderPath) return true;

      final content = json.encode({'title': bookmark.title, 'url': bookmark.url});
      final toFilename = bookmarkFilename(bookmark.title, bookmark.url);
      final toFilePath = '$toFolderPath/$toFilename';

      await api.createOrUpdateFile(toFilePath, content, 'Move bookmark: ${bookmark.title}');

      final toOrderPath = '$toFolderPath/_order.json';
      String? toOrderJson;
      String? toOrderSha;
      try {
        toOrderJson = await api.getFileContent(toOrderPath);
        final meta = await api.getFileMeta(toOrderPath);
        toOrderSha = meta?.sha;
      } catch (_) {}
      final toOrderList = _orderListFromJson(toOrderJson);
      if (!toOrderList.contains(toFilename)) {
        toOrderList.add(toFilename);
        await api.createOrUpdateFile(
          toOrderPath,
          const JsonEncoder.withIndent('  ').convert(toOrderList),
          'Update order: add $toFilename',
          sha: toOrderSha,
        );
      }

      final fileMeta = await api.getFileMeta(fromFilePath);
      if (fileMeta != null && fileMeta.sha != null) {
        await api.deleteFile(fromFilePath, fileMeta.sha!, 'Move bookmark: ${bookmark.title}');
      }

      final fromOrderPath = '$fromFolderPath/_order.json';
      String? fromOrderJson;
      String? fromOrderSha;
      try {
        fromOrderJson = await api.getFileContent(fromOrderPath);
        final meta = await api.getFileMeta(fromOrderPath);
        fromOrderSha = meta?.sha;
      } catch (_) {}
      final fromOrderList = _orderListFromJson(fromOrderJson);
      fromOrderList.remove(sourceFilename);
      await api.createOrUpdateFile(
        fromOrderPath,
        const JsonEncoder.withIndent('  ').convert(fromOrderList),
        'Update order: remove $sourceFilename',
        sha: fromOrderSha,
      );

      return true;
    } finally {
      api.close();
    }
  }

  /// Deletes a bookmark from a folder in the repo.
  /// Removes the JSON file and updates _order.json.
  Future<bool> deleteBookmarkFromFolder(
    GithubCredentials creds,
    String folderPath,
    Bookmark bookmark,
  ) async {
    final api = GithubApi(
      token: creds.token,
      owner: creds.owner,
      repo: creds.repo,
      branch: creds.branch,
      basePath: creds.basePath,
    );
    try {
      final filename = bookmark.filename ?? bookmarkFilename(bookmark.title, bookmark.url);
      final filePath = '$folderPath/$filename';

      final fileMeta = await api.getFileMeta(filePath);
      if (fileMeta == null || fileMeta.sha == null) return false;

      await api.deleteFile(filePath, fileMeta.sha!, 'Delete bookmark: ${bookmark.title}');

      final orderPath = '$folderPath/_order.json';
      String? orderJson;
      String? orderSha;
      try {
        orderJson = await api.getFileContent(orderPath);
        final meta = await api.getFileMeta(orderPath);
        orderSha = meta?.sha;
      } catch (_) {}

      final orderList = _orderListFromJson(orderJson);
      orderList.remove(filename);
      await api.createOrUpdateFile(
        orderPath,
        const JsonEncoder.withIndent('  ').convert(orderList),
        'Update order: remove $filename',
        sha: orderSha,
      );

      return true;
    } finally {
      api.close();
    }
  }

  List<dynamic> _orderListFromJson(String? jsonStr) {
    if (jsonStr == null || jsonStr.trim().isEmpty) return [];
    try {
      final decoded = json.decode(jsonStr);
      if (decoded is List) return List<dynamic>.from(decoded);
    } catch (_) {}
    return [];
  }

  /// Updates _order.json in a folder to match the given order entries.
  Future<bool> updateOrderInFolder(
    GithubCredentials creds,
    String folderPath,
    List<OrderEntry> orderEntries,
  ) async {
    final api = GithubApi(
      token: creds.token,
      owner: creds.owner,
      repo: creds.repo,
      branch: creds.branch,
      basePath: creds.basePath,
    );
    try {
      final orderPath = '$folderPath/_order.json';
      final list = orderEntries.map((e) {
        if (e.isFile) return e.filename!;
        return {'dir': e.dirName, 'title': e.title ?? e.dirName};
      }).toList();
      final orderJson = const JsonEncoder.withIndent('  ').convert(list);

      String? sha;
      try {
        final meta = await api.getFileMeta(orderPath);
        sha = meta?.sha;
      } catch (_) {}

      await api.createOrUpdateFile(
        orderPath,
        orderJson,
        'Reorder bookmarks',
        sha: sha,
      );
      return true;
    } finally {
      api.close();
    }
  }

  /// Validates that the token and repo are accessible.
  /// Returns the list of root folder names (dirs at base path) on success.
  Future<List<String>> testConnection(GithubCredentials creds) async {
    final api = GithubApi(
      token: creds.token,
      owner: creds.owner,
      repo: creds.repo,
      branch: creds.branch,
      basePath: creds.basePath,
    );
    try {
      final entries = await api.getContents(creds.basePath);
      return entries
          .where((e) => e.type == 'dir')
          .map((e) => e.name)
          .toList();
    } finally {
      api.close();
    }
  }

  Future<List<BookmarkFolder>> _fetchRootFolders(
    GithubApi api,
    String basePath,
  ) async {
    final entries = await api.getContents(basePath);
    final dirs = entries.where((e) => e.type == 'dir').toList();
    final rootFolders = <BookmarkFolder>[];

    for (final dir in dirs) {
      final folderPath =
          basePath.isEmpty ? dir.name : '$basePath/${dir.name}';
      final folder = await _fetchFolder(api, folderPath, dir.name);
      if (_hasContent(folder)) {
        rootFolders.add(folder);
      }
    }

    return rootFolders;
  }

  Future<BookmarkFolder> _fetchFolder(
    GithubApi api,
    String path,
    String title, {
    String? dirName,
  }) async {
    final entries = await api.getContents(path);
    final entriesByName = {for (final e in entries) e.name: e};

    List<BookmarkNode> children = [];
    List<OrderEntry> orderEntries = [];

    String? orderJson;
    final orderEntry = entriesByName['_order.json'];
    if (orderEntry != null) {
      if (orderEntry.content != null) {
        orderJson = api.decodeContent(orderEntry.content!);
      } else {
        try {
          final orderPath = orderEntry.path ?? '$path/_order.json';
          orderJson = await api.getFileContent(orderPath);
        } catch (_) {}
      }
    }
    if (orderJson != null) {
      orderEntries = _parseOrder(orderJson);
      // Append dirs from disk not in _order.json (like extension: "picked up automatically")
      final orderDirNames = orderEntries
          .where((e) => !e.isFile)
          .map((e) => e.dirName!)
          .toSet();
      for (final e in entries) {
        if (e.type == 'dir' && !orderDirNames.contains(e.name)) {
          orderEntries = [...orderEntries, OrderEntry.folder(e.name, e.name)];
        }
      }
      // Append files from disk not in _order.json
      final orderFiles = orderEntries.where((e) => e.isFile).map((e) => e.filename!).toSet();
      for (final e in entries) {
        if (e.type == 'file' &&
            e.name.endsWith('.json') &&
            e.name != '_order.json' &&
            !orderFiles.contains(e.name)) {
          orderEntries = [...orderEntries, OrderEntry.file(e.name)];
        }
      }
    } else {
      // No _order.json: use natural order (files first, then dirs)
      final files = entries
          .where((e) => e.type == 'file' && e.name.endsWith('.json'))
          .where((e) => e.name != '_order.json')
          .map((e) => OrderEntry.file(e.name))
          .toList();
      final subdirs = entries
          .where((e) => e.type == 'dir')
          .map((e) => OrderEntry.folder(e.name, e.name))
          .toList();
      orderEntries = [...files, ...subdirs];
    }

    for (final entry in orderEntries) {
      if (entry.isFile) {
        final filename = entry.filename!;
        if (!filename.endsWith('.json') || filename == '_order.json') {
          continue;
        }
        String? content;
        final fileEntry = entriesByName[filename];
        final filePath = fileEntry?.path ?? '$path/$filename';
        if (fileEntry != null && fileEntry.content != null) {
          content = api.decodeContent(fileEntry.content!);
        } else {
          try {
            content = await api.getFileContent(filePath);
          } catch (_) {
            continue;
          }
        }
        final bookmark = _parseBookmark(content, filename);
        if (bookmark != null) {
          children.add(bookmark);
        }
      } else {
        final dirName = entry.dirName!;
        var subdirEntry = entriesByName[dirName];
        if (subdirEntry == null) {
          for (final e in entries) {
            if (e.type == 'dir' && e.name == dirName) {
              subdirEntry = e;
              break;
            }
          }
        }
        if (subdirEntry != null && subdirEntry.type == 'dir') {
          final subfolder = await _fetchFolder(
            api,
            '$path/${subdirEntry.name}',
            entry.title ?? subdirEntry.name,
            dirName: subdirEntry.name,
          );
          // Always add subfolders to preserve structure (incl. empty ones)
          children.add(subfolder);
        }
      }
    }

    final dName = dirName ?? path.split('/').lastOrNull;
    return BookmarkFolder(title: title, children: children, dirName: dName);
  }

  /// Returns true if folder has bookmarks or subfolders (incl. empty subfolders).
  bool _hasContent(BookmarkFolder folder) {
    if (folder.children.isNotEmpty) return true;
    return false;
  }

  List<OrderEntry> _parseOrder(String jsonStr) {
    final decoded = json.decode(jsonStr);
    List<dynamic> list;
    if (decoded is List) {
      list = decoded;
    } else if (decoded is Map) {
      list = (decoded['order'] ?? decoded['items'] ?? decoded['entries'] ?? []) as List<dynamic>? ?? [];
    } else {
      return [];
    }

    return list.map((e) {
      if (e is String) {
        return OrderEntry.file(e);
      }
      if (e is Map) {
        final dir = e['dir'] as String?;
        final title = e['title'] as String?;
        if (dir != null) {
          return OrderEntry.folder(dir, title ?? dir);
        }
      }
      return null;
    }).whereType<OrderEntry>().toList();
  }

  Bookmark? _parseBookmark(String jsonStr, [String? filename]) {
    try {
      final map = json.decode(jsonStr) as Map<String, dynamic>;
      final title = (map['title'] ?? map['name']) as String?;
      final url = (map['url'] ?? map['link'] ?? map['href']) as String?;
      if (title != null &&
          title.isNotEmpty &&
          url != null &&
          url.toString().isNotEmpty) {
        return Bookmark(title: title, url: url.toString(), filename: filename);
      }
    } catch (_) {}
    return null;
  }
}

/// Represents an entry in _order.json.
class OrderEntry {
  OrderEntry._();

  factory OrderEntry.file(String filename) => OrderEntry._()
    .._filename = filename
    .._isFile = true;

  factory OrderEntry.folder(String dirName, String title) => OrderEntry._()
    .._dirName = dirName
    .._title = title
    .._isFile = false;

  String? _filename;
  String? _dirName;
  String? _title;
  bool _isFile = false;

  String? get filename => _filename;
  String? get dirName => _dirName;
  String? get title => _title;
  bool get isFile => _isFile;
}
