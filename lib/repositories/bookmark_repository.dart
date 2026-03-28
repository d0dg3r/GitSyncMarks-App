import 'dart:convert';

import '../config/github_credentials.dart';
import '../models/bookmark_node.dart';
import '../services/bookmark_parser.dart';
import '../services/git_data_api.dart';
import '../services/github_api.dart';
import '../services/remote_fetch.dart';
import '../utils/bookmark_filename.dart';

/// Result of fetching bookmarks from GitHub.
class FetchResult {
  FetchResult({
    required this.rootFolders,
    required this.commitSha,
    required this.fileMap,
    required this.shaMap,
  });

  FetchResult.empty()
      : rootFolders = [],
        commitSha = null,
        fileMap = {},
        shaMap = {};

  final List<BookmarkFolder> rootFolders;
  final String? commitSha;
  final Map<String, String> fileMap;
  final Map<String, String> shaMap;
}

/// Orchestrates syncing bookmarks from GitHub and parsing the tree.
///
/// Reads use the Git Data API (tree walk + batched blob fetch) for efficiency.
/// Writes use atomic multi-file commits for consistency.
/// Test-connection and folder browsing still use the Contents API.
class BookmarkRepository {
  BookmarkRepository();

  static const Set<String> _hiddenRootDirs = {'profiles'};

  // ---------------------------------------------------------------------------
  // Read: Git Data API (tree walk)
  // ---------------------------------------------------------------------------

  /// Fetches the full bookmark tree from GitHub using the Git Data API.
  ///
  /// Returns a [FetchResult] containing the parsed tree, commit SHA, and raw
  /// file/sha maps (used by sync state for three-way merge).
  ///
  /// [baseFiles] allows reusing content from the last sync to skip unchanged
  /// blob downloads.
  Future<FetchResult> fetchBookmarks(
    GithubCredentials creds, {
    Map<String, SyncFileEntry>? baseFiles,
  }) async {
    final api = GitDataApi(
      token: creds.token,
      owner: creds.owner,
      repo: creds.repo,
      branch: creds.branch,
    );
    try {
      final remote = await fetchRemoteFileMap(
        api,
        creds.basePath,
        baseFiles: baseFiles,
      );
      if (remote == null) return FetchResult.empty();

      final rootFolders =
          fileMapToBookmarkTree(remote.fileMap, creds.basePath);
      return FetchResult(
        rootFolders: rootFolders,
        commitSha: remote.commitSha,
        fileMap: remote.fileMap,
        shaMap: remote.shaMap,
      );
    } finally {
      api.close();
    }
  }

  // ---------------------------------------------------------------------------
  // Write: Atomic commits via Git Data API
  // ---------------------------------------------------------------------------

  /// Adds a bookmark to a folder in the repo (single atomic commit).
  Future<bool> addBookmarkToFolder(
    GithubCredentials creds,
    String folderPath,
    String title,
    String url,
  ) async {
    final api = _createContentsApi(creds);
    final gitApi = _createGitDataApi(creds);
    try {
      final filename = bookmarkFilename(title, url);
      final content = json.encode({'title': title, 'url': url});

      final orderPath = '$folderPath/_order.json';
      final orderList = await _readOrderList(api, orderPath);

      if (!orderList.contains(filename)) {
        orderList.insert(0, filename);
      }

      final fileChanges = <String, String?>{
        '$folderPath/$filename': content,
        orderPath: const JsonEncoder.withIndent('  ').convert(orderList),
        '${creds.basePath}/_index.json':
            const JsonEncoder.withIndent('  ').convert({'version': 2}),
      };

      await gitApi.atomicCommit('Add bookmark: $title', fileChanges);
      return true;
    } finally {
      api.close();
      gitApi.close();
    }
  }

  /// Moves a bookmark between folders (single atomic commit).
  Future<bool> moveBookmarkToFolder(
    GithubCredentials creds,
    String fromFolderPath,
    String toFolderPath,
    Bookmark bookmark,
  ) async {
    if (fromFolderPath == toFolderPath) return true;

    final api = _createContentsApi(creds);
    final gitApi = _createGitDataApi(creds);
    try {
      final sourceFilename =
          bookmark.filename ?? bookmarkFilename(bookmark.title, bookmark.url);
      final toFilename = bookmarkFilename(bookmark.title, bookmark.url);
      final content =
          json.encode({'title': bookmark.title, 'url': bookmark.url});

      final fromOrderPath = '$fromFolderPath/_order.json';
      final toOrderPath = '$toFolderPath/_order.json';

      final fromOrderList = await _readOrderList(api, fromOrderPath);
      final toOrderList = await _readOrderList(api, toOrderPath);

      fromOrderList.remove(sourceFilename);
      if (!toOrderList.contains(toFilename)) {
        toOrderList.add(toFilename);
      }

      final fileChanges = <String, String?>{
        '$toFolderPath/$toFilename': content,
        '$fromFolderPath/$sourceFilename': null,
        fromOrderPath:
            const JsonEncoder.withIndent('  ').convert(fromOrderList),
        toOrderPath: const JsonEncoder.withIndent('  ').convert(toOrderList),
        '${creds.basePath}/_index.json':
            const JsonEncoder.withIndent('  ').convert({'version': 2}),
      };

      await gitApi.atomicCommit(
        'Move bookmark: ${bookmark.title}',
        fileChanges,
      );
      return true;
    } finally {
      api.close();
      gitApi.close();
    }
  }

  /// Deletes a bookmark from a folder (single atomic commit).
  Future<bool> deleteBookmarkFromFolder(
    GithubCredentials creds,
    String folderPath,
    Bookmark bookmark,
  ) async {
    final api = _createContentsApi(creds);
    final gitApi = _createGitDataApi(creds);
    try {
      final filename =
          bookmark.filename ?? bookmarkFilename(bookmark.title, bookmark.url);
      final filePath = '$folderPath/$filename';

      final orderPath = '$folderPath/_order.json';
      final orderList = await _readOrderList(api, orderPath);
      orderList.remove(filename);

      final fileChanges = <String, String?>{
        filePath: null,
        orderPath: const JsonEncoder.withIndent('  ').convert(orderList),
      };

      await gitApi.atomicCommit(
        'Delete bookmark: ${bookmark.title}',
        fileChanges,
      );
      return true;
    } finally {
      api.close();
      gitApi.close();
    }
  }

  /// Updates _order.json in a folder to match the given order entries.
  Future<bool> updateOrderInFolder(
    GithubCredentials creds,
    String folderPath,
    List<OrderEntry> orderEntries,
  ) async {
    final gitApi = _createGitDataApi(creds);
    try {
      final list = orderEntries.map((e) {
        if (e.isFile) return e.filename!;
        return {'dir': e.dirName, 'title': e.title ?? e.dirName};
      }).toList();
      final orderJson = const JsonEncoder.withIndent('  ').convert(list);

      final fileChanges = <String, String?>{
        '$folderPath/_order.json': orderJson,
        '${creds.basePath}/_index.json':
            const JsonEncoder.withIndent('  ').convert({'version': 2}),
      };

      await gitApi.atomicCommit('Reorder bookmarks', fileChanges);
      return true;
    } finally {
      gitApi.close();
    }
  }

  /// Edits a bookmark's title and/or URL (single atomic commit).
  ///
  /// If the URL changed, the filename changes too (delete old + create new).
  Future<bool> editBookmarkInFolder(
    GithubCredentials creds,
    String folderPath,
    Bookmark bookmark, {
    required String newTitle,
    required String newUrl,
  }) async {
    final api = _createContentsApi(creds);
    final gitApi = _createGitDataApi(creds);
    try {
      final oldFilename =
          bookmark.filename ?? bookmarkFilename(bookmark.title, bookmark.url);
      final newFilename = bookmarkFilename(newTitle, newUrl);
      final content = json.encode({'title': newTitle, 'url': newUrl});

      final fileChanges = <String, String?>{};

      if (oldFilename == newFilename) {
        fileChanges['$folderPath/$oldFilename'] = content;
      } else {
        fileChanges['$folderPath/$oldFilename'] = null;
        fileChanges['$folderPath/$newFilename'] = content;

        final orderPath = '$folderPath/_order.json';
        final orderList = await _readOrderList(api, orderPath);
        final idx = orderList.indexOf(oldFilename);
        if (idx >= 0) {
          orderList[idx] = newFilename;
        } else {
          orderList.add(newFilename);
        }
        fileChanges[orderPath] =
            const JsonEncoder.withIndent('  ').convert(orderList);
      }

      await gitApi.atomicCommit('Edit bookmark: $newTitle', fileChanges);
      return true;
    } finally {
      api.close();
      gitApi.close();
    }
  }

  /// Creates a new subfolder (single atomic commit).
  Future<bool> createFolder(
    GithubCredentials creds,
    String parentFolderPath,
    String folderTitle,
  ) async {
    final api = _createContentsApi(creds);
    final gitApi = _createGitDataApi(creds);
    try {
      final dirName = _slugify(folderTitle);
      final newFolderPath = '$parentFolderPath/$dirName';

      final orderPath = '$parentFolderPath/_order.json';
      final orderList = await _readOrderList(api, orderPath);

      final folderEntry = {'dir': dirName, 'title': folderTitle};
      final alreadyExists = orderList.any((e) =>
          e is Map && e['dir'] == dirName);
      if (!alreadyExists) {
        orderList.add(folderEntry);
      }

      final fileChanges = <String, String?>{
        '$newFolderPath/_order.json':
            const JsonEncoder.withIndent('  ').convert([]),
        orderPath: const JsonEncoder.withIndent('  ').convert(orderList),
        '${creds.basePath}/_index.json':
            const JsonEncoder.withIndent('  ').convert({'version': 2}),
      };

      await gitApi.atomicCommit('Create folder: $folderTitle', fileChanges);
      return true;
    } finally {
      api.close();
      gitApi.close();
    }
  }

  static String _slugify(String str) {
    if (str.isEmpty) return 'untitled';
    var slug = str.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    slug = slug.replaceAll(RegExp(r'^-+|-+$'), '');
    if (slug.length > 40) slug = slug.substring(0, 40);
    return slug.isEmpty ? 'untitled' : slug;
  }

  // ---------------------------------------------------------------------------
  // Test connection (Contents API — simple and sufficient)
  // ---------------------------------------------------------------------------

  /// Validates token and repo access. Returns root folder names.
  Future<List<String>> testConnection(GithubCredentials creds) async {
    final api = _createContentsApi(creds);
    try {
      final entries = await api.getContents(creds.basePath);
      return entries
          .where((e) => e.type == 'dir' && _isVisibleRootDir(e.name))
          .map((e) => e.name)
          .toList();
    } finally {
      api.close();
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  GithubApi _createContentsApi(GithubCredentials creds) => GithubApi(
        token: creds.token,
        owner: creds.owner,
        repo: creds.repo,
        branch: creds.branch,
        basePath: creds.basePath,
      );

  GitDataApi _createGitDataApi(GithubCredentials creds) => GitDataApi(
        token: creds.token,
        owner: creds.owner,
        repo: creds.repo,
        branch: creds.branch,
      );

  /// Reads _order.json via Contents API and returns a mutable list.
  Future<List<dynamic>> _readOrderList(GithubApi api, String path) async {
    try {
      final content = await api.getFileContent(path);
      final decoded = json.decode(content);
      if (decoded is List) return List<dynamic>.from(decoded);
    } catch (_) {}
    return [];
  }

  bool _isVisibleRootDir(String name) => !_hiddenRootDirs.contains(name);
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
