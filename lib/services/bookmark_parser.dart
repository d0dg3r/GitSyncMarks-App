import 'dart:convert';

import '../models/bookmark_node.dart';

/// Roles that are synced (matches the extension's SYNC_ROLES).
const List<String> syncRoles = ['toolbar', 'other'];

/// Converts a flat file map (path -> content) into a list of root
/// [BookmarkFolder]s, mirroring the extension's `fileMapToBookmarkTree`.
List<BookmarkFolder> fileMapToBookmarkTree(
  Map<String, String> files,
  String basePath,
) {
  final base = basePath.replaceAll(RegExp(r'/+$'), '');
  final roles = <String>{};
  for (final path in files.keys) {
    final rel = path.substring(base.length + 1);
    final slash = rel.indexOf('/');
    if (slash > 0) {
      final role = rel.substring(0, slash);
      if (syncRoles.contains(role)) roles.add(role);
    }
  }

  final result = <BookmarkFolder>[];
  for (final role in syncRoles) {
    if (!roles.contains(role)) continue;
    final children = _buildFolderChildren(files, '$base/$role');
    result.add(BookmarkFolder(title: role, children: children, dirName: role));
  }
  return result;
}

/// Converts a bookmark tree back to a file map (path -> content).
///
/// Used by the sync engine to compute local changes before pushing.
Map<String, String> bookmarkTreeToFileMap(
  List<BookmarkFolder> rootFolders,
  String basePath,
) {
  final base = basePath.replaceAll(RegExp(r'/+$'), '');
  final files = <String, String>{};

  for (final folder in rootFolders) {
    final role = folder.dirName ?? folder.title;
    if (!syncRoles.contains(role)) continue;
    _processFolder(folder, '$base/$role', files);
  }

  files['$base/_index.json'] =
      const JsonEncoder.withIndent('  ').convert({'version': 2});
  return files;
}

// ---------------------------------------------------------------------------
// File map -> Tree
// ---------------------------------------------------------------------------

List<BookmarkNode> _buildFolderChildren(
  Map<String, String> files,
  String dirPath,
) {
  final order = _parseOrderJson(files, dirPath);
  if (order == null) return [];

  final children = <BookmarkNode>[];
  final processedFolders = <String>{};
  final seenKeys = <String>{};
  final seenFolderTitles = <String, int>{};

  for (final entry in order) {
    final key = _orderEntryKey(entry);
    if (seenKeys.contains(key)) continue;
    seenKeys.add(key);

    if (entry is String && entry.endsWith('.json')) {
      final filePath = '$dirPath/$entry';
      final content = files[filePath];
      if (content == null) continue;
      final bm = _parseBookmarkJson(content, entry);
      if (bm != null) children.add(bm);
    } else if (entry is Map) {
      final dir = entry['dir'] as String?;
      if (dir == null) continue;
      final folderPath = '$dirPath/$dir';
      if (!files.containsKey('$folderPath/_order.json')) continue;
      processedFolders.add(dir);
      final folderTitle = (entry['title'] as String?) ?? dir;

      if (seenFolderTitles.containsKey(folderTitle)) {
        final idx = seenFolderTitles[folderTitle]!;
        final existing = children[idx] as BookmarkFolder;
        final extra = _buildFolderChildren(files, folderPath);
        children[idx] = BookmarkFolder(
          title: existing.title,
          children: [...existing.children, ...extra],
          dirName: existing.dirName,
        );
        continue;
      }
      seenFolderTitles[folderTitle] = children.length;
      children.add(BookmarkFolder(
        title: folderTitle,
        children: _buildFolderChildren(files, folderPath),
        dirName: dir,
      ));
    } else if (entry is String) {
      final folderPath = '$dirPath/$entry';
      if (!files.containsKey('$folderPath/_order.json')) continue;
      processedFolders.add(entry);
      if (seenFolderTitles.containsKey(entry)) {
        final idx = seenFolderTitles[entry]!;
        final existing = children[idx] as BookmarkFolder;
        final extra = _buildFolderChildren(files, folderPath);
        children[idx] = BookmarkFolder(
          title: existing.title,
          children: [...existing.children, ...extra],
          dirName: existing.dirName,
        );
        continue;
      }
      seenFolderTitles[entry] = children.length;
      children.add(BookmarkFolder(
        title: entry,
        children: _buildFolderChildren(files, folderPath),
        dirName: entry,
      ));
    }
  }

  // Orphan subfolders not listed in _order.json
  for (final orphan
      in _findOrphanSubfolders(files, dirPath, processedFolders)) {
    final title = _orphanDisplayTitle(orphan);
    if (seenFolderTitles.containsKey(title)) {
      final idx = seenFolderTitles[title]!;
      final existing = children[idx] as BookmarkFolder;
      final extra = _buildFolderChildren(files, '$dirPath/$orphan');
      children[idx] = BookmarkFolder(
        title: existing.title,
        children: [...existing.children, ...extra],
        dirName: existing.dirName,
      );
      continue;
    }
    seenFolderTitles[title] = children.length;
    children.add(BookmarkFolder(
      title: title,
      children: _buildFolderChildren(files, '$dirPath/$orphan'),
      dirName: orphan,
    ));
  }

  // Orphan bookmark files not listed in _order.json
  final knownFiles = <String>{};
  for (final entry in order) {
    if (entry is String) {
      knownFiles.add(entry);
    } else if (entry is Map && entry['dir'] != null) {
      knownFiles.add(entry['dir'] as String);
    }
  }
  final prefix = '$dirPath/';
  for (final path in files.keys) {
    if (!path.startsWith(prefix)) continue;
    final rel = path.substring(prefix.length);
    if (rel.contains('/')) continue;
    if (!rel.endsWith('.json') || rel.startsWith('_')) continue;
    if (knownFiles.contains(rel)) continue;
    final content = files[path];
    if (content == null) continue;
    final bm = _parseBookmarkJson(content, rel);
    if (bm != null) children.add(bm);
  }

  return children;
}

List<dynamic>? _parseOrderJson(Map<String, String> files, String dirPath) {
  final content = files['$dirPath/_order.json'];
  if (content == null) return null;
  try {
    final decoded = json.decode(content);
    return decoded is List ? decoded : null;
  } catch (_) {
    return null;
  }
}

String _orderEntryKey(dynamic entry) {
  if (entry is String) return entry;
  if (entry is Map && entry['dir'] != null) return 'dir:${entry['dir']}';
  return json.encode(entry);
}

List<String> _findOrphanSubfolders(
  Map<String, String> files,
  String dirPath,
  Set<String> processedFolders,
) {
  final orphans = <String>[];
  final prefix = '$dirPath/';
  for (final path in files.keys) {
    if (!path.startsWith(prefix)) continue;
    final rel = path.substring(prefix.length);
    final parts = rel.split('/');
    if (parts.length >= 2 && parts[1] == '_order.json') {
      final folderName = parts[0];
      if (processedFolders.contains(folderName)) continue;
      processedFolders.add(folderName);
      orphans.add(folderName);
    }
  }
  return orphans;
}

String _orphanDisplayTitle(String folderName) {
  return folderName
      .replaceAll('-', ' ')
      .replaceAllMapped(
        RegExp(r'\b\w'),
        (m) => m.group(0)!.toUpperCase(),
      );
}

Bookmark? _parseBookmarkJson(String content, [String? filename]) {
  try {
    final map = json.decode(content) as Map<String, dynamic>;
    final title = (map['title'] ?? map['name']) as String?;
    final url = (map['url'] ?? map['link'] ?? map['href'])?.toString();
    if (title != null && title.isNotEmpty && url != null && url.isNotEmpty) {
      return Bookmark(title: title, url: url, filename: filename);
    }
  } catch (_) {}
  return null;
}

// ---------------------------------------------------------------------------
// Tree -> File map
// ---------------------------------------------------------------------------

/// Merges sibling [BookmarkFolder] children that share the same [BookmarkFolder.title]
/// (parity with the extension’s `processFolder` — avoids duplicate on-disk folder names).
List<BookmarkNode> _mergeSiblingFoldersByTitle(List<BookmarkNode> children) {
  final result = <BookmarkNode>[];
  final titleToIndex = <String, int>{};
  for (final child in children) {
    if (child is Bookmark) {
      result.add(child);
    } else if (child is BookmarkFolder) {
      if (titleToIndex.containsKey(child.title)) {
        final idx = titleToIndex[child.title]!;
        final existing = result[idx] as BookmarkFolder;
        result[idx] = BookmarkFolder(
          title: existing.title,
          dirName: existing.dirName ?? child.dirName,
          children: [...existing.children, ...child.children],
        );
      } else {
        titleToIndex[child.title] = result.length;
        result.add(child);
      }
    }
  }
  return result;
}

void _processFolder(
  BookmarkFolder folder,
  String dirPath,
  Map<String, String> files,
) {
  final order = <dynamic>[];
  for (final child in _mergeSiblingFoldersByTitle(folder.children)) {
    switch (child) {
      case Bookmark():
        final filename = child.filename ??
            _generateFilename(child.title, child.url);
        final content = json.encode({'title': child.title, 'url': child.url});
        files['$dirPath/$filename'] = content;
        order.add(filename);
      case BookmarkFolder():
        final dirName = child.dirName ?? _slugify(child.title);
        _processFolder(child, '$dirPath/$dirName', files);
        order.add({'dir': dirName, 'title': child.title});
    }
  }
  files['$dirPath/_order.json'] =
      const JsonEncoder.withIndent('  ').convert(order);
}

// ---------------------------------------------------------------------------
// Slug / filename helpers (mirror extension's bookmark-serializer.js)
// ---------------------------------------------------------------------------

String _slugify(String str) {
  if (str.isEmpty) return 'untitled';
  var slug = str.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  slug = slug.replaceAll(RegExp(r'^-+|-+$'), '');
  if (slug.length > 40) slug = slug.substring(0, 40);
  return slug.isEmpty ? 'untitled' : slug;
}

/// FNV-1a hash, base-36, 4 chars (matches extension).
String _shortHash(String str) {
  var h = 0x811c9dc5;
  for (var i = 0; i < str.length; i++) {
    h ^= str.codeUnitAt(i);
    h = (h * 0x01000193) & 0xFFFFFFFF;
  }
  return (h).toUnsigned(32).toRadixString(36).padLeft(4, '0').substring(0, 4);
}

String _generateFilename(String title, String url) {
  return '${_slugify(title)}_${_shortHash(url)}.json';
}
