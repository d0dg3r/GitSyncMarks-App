import 'dart:convert';

import '../config/github_credentials.dart';
import '../models/bookmark_node.dart';
import 'bookmark_parser.dart';
import 'git_data_api.dart';
import 'remote_fetch.dart';
import 'sync_state.dart';

/// A bookmark diff entry for the history preview UI.
class DiffBookmark {
  DiffBookmark({required this.title, required this.url, required this.path});

  final String title;
  final String url;
  final String path;
}

/// A changed bookmark in the diff preview (old vs new values).
class ChangedBookmark {
  ChangedBookmark({
    required this.path,
    required this.title,
    required this.url,
    this.oldTitle,
    this.oldUrl,
  });

  final String path;
  final String title;
  final String url;
  final String? oldTitle;
  final String? oldUrl;
}

/// Result of a diff preview between a commit and the current state.
class DiffPreviewResult {
  DiffPreviewResult({
    required this.success,
    this.added = const [],
    this.removed = const [],
    this.changed = const [],
    this.message,
  });

  final bool success;
  final List<DiffBookmark> added;
  final List<DiffBookmark> removed;
  final List<ChangedBookmark> changed;
  final String? message;

  int get totalChanges => added.length + removed.length + changed.length;
}

/// Provides sync history operations: listing commits, previewing diffs,
/// restoring from past commits, and undoing the last sync.
class SyncHistoryService {
  SyncHistoryService({required SyncStateService syncState})
      : _syncState = syncState;

  final SyncStateService _syncState;

  /// Lists recent commits that touched the bookmark base path.
  Future<List<CommitEntry>> listHistory(
    GithubCredentials creds, {
    int perPage = 20,
  }) async {
    final api = _createApi(creds);
    try {
      final basePath = creds.basePath.replaceAll(RegExp(r'/+$'), '');
      return await api.listCommits(path: basePath, perPage: perPage);
    } finally {
      api.close();
    }
  }

  /// Previews the diff between a target commit and the current local bookmarks.
  Future<DiffPreviewResult> previewCommitDiff(
    GithubCredentials creds,
    String commitSha,
    List<BookmarkFolder> currentTree,
  ) async {
    final api = _createApi(creds);
    try {
      final basePath = creds.basePath.replaceAll(RegExp(r'/+$'), '');

      final remote = await fetchRemoteFileMapAtCommit(api, basePath, commitSha);
      if (remote.fileMap.isEmpty) {
        return DiffPreviewResult(
          success: false,
          message: 'No bookmarks found at this commit',
        );
      }

      final localFiles = bookmarkTreeToFileMap(currentTree, basePath);

      final targetBm = _filterBookmarkFiles(remote.fileMap);
      final localBm = _filterBookmarkFiles(localFiles);

      final added = <DiffBookmark>[];
      final removed = <DiffBookmark>[];
      final changed = <ChangedBookmark>[];

      for (final entry in targetBm.entries) {
        if (!localBm.containsKey(entry.key)) {
          added.add(_parseDiffBookmark(entry.value, entry.key));
        } else if (localBm[entry.key] != entry.value) {
          final target = _parseDiffBookmark(entry.value, entry.key);
          final local = _parseDiffBookmark(localBm[entry.key]!, entry.key);
          changed.add(ChangedBookmark(
            path: entry.key,
            title: target.title,
            url: target.url,
            oldTitle: local.title,
            oldUrl: local.url,
          ));
        }
      }

      for (final entry in localBm.entries) {
        if (!targetBm.containsKey(entry.key)) {
          removed.add(_parseDiffBookmark(entry.value, entry.key));
        }
      }

      return DiffPreviewResult(
        success: true,
        added: added,
        removed: removed,
        changed: changed,
      );
    } finally {
      api.close();
    }
  }

  /// Restores bookmarks from a specific commit. Fetches the tree at that
  /// commit and pushes it as the new HEAD.
  Future<RestoreResult> restoreFromCommit(
    GithubCredentials creds,
    String commitSha,
    String profileId, {
    String? deviceId,
  }) async {
    final api = _createApi(creds);
    try {
      final basePath = creds.basePath.replaceAll(RegExp(r'/+$'), '');
      final prevCommitSha = _syncState.getLastCommitSha(profileId);

      final remote = await fetchRemoteFileMapAtCommit(api, basePath, commitSha);
      if (remote.fileMap.isEmpty) {
        return RestoreResult(
          success: false,
          message: 'No bookmarks found at this commit',
        );
      }

      // Fetch current remote to compute changes
      final current = await fetchRemoteFileMap(api, basePath);
      final currentFiles = current?.fileMap ?? {};

      final fileChanges = <String, String?>{};
      for (final entry in remote.fileMap.entries) {
        if (currentFiles[entry.key] != entry.value) {
          fileChanges[entry.key] = entry.value;
        }
      }
      for (final path in currentFiles.keys) {
        if (!remote.fileMap.containsKey(path) &&
            !isGeneratedOrSettingsPath(path)) {
          fileChanges[path] = null;
        }
      }

      if (fileChanges.isNotEmpty) {
        final device = deviceId != null && deviceId.length >= 8
            ? deviceId.substring(0, 8)
            : 'app';
        final msg =
            'Restore from ${commitSha.substring(0, 7)} by $device — ${DateTime.now().toUtc().toIso8601String()}';
        await api.atomicCommit(msg, fileChanges);
      }

      final tree = fileMapToBookmarkTree(remote.fileMap, basePath);

      // Re-fetch to get accurate SHA map after our commit
      final freshRemote = await fetchRemoteFileMap(api, basePath);
      await _syncState.saveSyncState(
        profileId: profileId,
        commitSha: freshRemote?.commitSha ?? commitSha,
        shaMap: freshRemote?.shaMap ?? remote.shaMap,
        fileMap: remote.fileMap,
        previousCommitSha: prevCommitSha,
      );

      return RestoreResult(
        success: true,
        message: 'Restored from commit ${commitSha.substring(0, 7)}',
        rootFolders: tree,
        commitSha: freshRemote?.commitSha ?? commitSha,
      );
    } finally {
      api.close();
    }
  }

  /// Undoes the last sync by restoring from the previous commit.
  Future<RestoreResult> undoLastSync(
    GithubCredentials creds,
    String profileId, {
    String? deviceId,
  }) async {
    final prevSha = _syncState.getPreviousCommitSha(profileId);
    if (prevSha == null || prevSha.isEmpty) {
      return RestoreResult(
        success: false,
        message: 'No previous sync to undo',
      );
    }
    return restoreFromCommit(creds, prevSha, profileId, deviceId: deviceId);
  }

  /// Extracts the client/device id from a GitSyncMarks commit message.
  /// Messages follow: "... from <deviceId> — <timestamp>"
  static String extractClientId(String? message) {
    if (message == null || message.isEmpty) return '';
    final match = RegExp(r'\sfrom\s+(.+?)\s+—\s').firstMatch(message);
    return match?.group(1)?.trim() ?? '';
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Map<String, String> _filterBookmarkFiles(Map<String, String> files) {
    final out = <String, String>{};
    for (final entry in files.entries) {
      if (!entry.key.endsWith('.json')) continue;
      if (entry.key.endsWith('/_order.json') ||
          entry.key.endsWith('/_index.json')) continue;
      if (isGeneratedOrSettingsPath(entry.key)) continue;
      out[entry.key] = entry.value;
    }
    return out;
  }

  DiffBookmark _parseDiffBookmark(String content, String path) {
    try {
      final map = json.decode(content) as Map<String, dynamic>;
      return DiffBookmark(
        title: (map['title'] as String?) ?? path.split('/').last,
        url: (map['url'] as String?) ?? '',
        path: path,
      );
    } catch (_) {
      return DiffBookmark(title: path.split('/').last, url: '', path: path);
    }
  }

  GitDataApi _createApi(GithubCredentials creds) => GitDataApi(
        token: creds.token,
        owner: creds.owner,
        repo: creds.repo,
        branch: creds.branch,
      );
}

/// Result of a restore operation.
class RestoreResult {
  RestoreResult({
    required this.success,
    required this.message,
    this.rootFolders,
    this.commitSha,
  });

  final bool success;
  final String message;
  final List<BookmarkFolder>? rootFolders;
  final String? commitSha;
}
