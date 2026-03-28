import '../config/github_credentials.dart';
import '../models/bookmark_node.dart';
import 'bookmark_parser.dart';
import 'debug_log.dart';
import 'git_data_api.dart';
import 'remote_fetch.dart';
import 'sync_diff.dart';
import 'sync_state.dart';

/// Outcome of a sync/push/pull operation.
class SyncResult {
  SyncResult({
    required this.success,
    required this.message,
    this.rootFolders,
    this.commitSha,
    this.fileMap,
    this.shaMap,
    this.hasConflict = false,
  });

  final bool success;
  final String message;
  final List<BookmarkFolder>? rootFolders;
  final String? commitSha;
  final Map<String, String>? fileMap;
  final Map<String, String>? shaMap;
  final bool hasConflict;
}

/// Coordinates three-way merge sync between the local cache and GitHub.
///
/// Adapts the browser extension's sync-core logic for a mobile/desktop app
/// where individual write operations (add/move/delete) go directly to GitHub,
/// and "sync" primarily means pulling changes from other devices.
class SyncEngine {
  SyncEngine({required SyncStateService syncState}) : _syncState = syncState;

  final SyncStateService _syncState;

  /// Bidirectional sync with three-way merge.
  ///
  /// 1. Load base state (last synced file map)
  /// 2. Build local file map from cached tree
  /// 3. Fetch remote file map from GitHub
  /// 4. Compute diffs and merge
  /// 5. Apply remote changes locally, push local changes to remote
  Future<SyncResult> sync({
    required GithubCredentials creds,
    required String profileId,
    required List<BookmarkFolder> cachedTree,
    String? deviceId,
  }) async {
    debugLog.log('sync: start profile=$profileId');
    final api = _createApi(creds);
    try {
      final basePath = creds.basePath.replaceAll(RegExp(r'/+$'), '');

      final baseSyncFiles = _syncState.getLastSyncFiles(profileId);
      final baseCommitSha = _syncState.getLastCommitSha(profileId);
      debugLog.log('sync: baseSha=${baseCommitSha ?? "none"}, baseFiles=${baseSyncFiles.length}');

      // 2. Fetch remote
      final remote = await fetchRemoteFileMap(
        api,
        basePath,
        baseFiles: baseSyncFiles.isNotEmpty ? baseSyncFiles : null,
      );

      debugLog.log('sync: remote files=${remote?.fileMap.length ?? 0}');

      if (baseSyncFiles.isEmpty) {
        debugLog.log('sync: first sync (no base state)');
        return _handleFirstSync(
          api: api,
          creds: creds,
          profileId: profileId,
          basePath: basePath,
          cachedTree: cachedTree,
          remote: remote,
          deviceId: deviceId,
        );
      }

      // 4. Build base content map and local file map
      final baseContentMap = <String, String>{};
      for (final entry in baseSyncFiles.entries) {
        baseContentMap[entry.key] = entry.value.content;
      }

      final localFiles = bookmarkTreeToFileMap(cachedTree, basePath);
      final remoteFiles = remote?.fileMap ?? {};

      // 5. Compute diffs (filtered)
      final localDiff = computeDiff(
        filterForDiff(baseContentMap),
        filterForDiff(localFiles),
      );
      final remoteDiff = computeDiff(
        filterForDiff(baseContentMap),
        filterForDiff(remoteFiles),
      );

      debugLog.log('sync: localDiff=${localDiff.hasChanges}, remoteDiff=${remoteDiff.hasChanges}');

      if (!localDiff.hasChanges && !remoteDiff.hasChanges) {
        return SyncResult(
          success: true,
          message: 'Everything is in sync',
          rootFolders: cachedTree,
          commitSha: remote?.commitSha ?? baseCommitSha,
          fileMap: remoteFiles,
          shaMap: remote?.shaMap ?? {},
        );
      }

      // 7. Only local changes -> push
      if (localDiff.hasChanges && !remoteDiff.hasChanges) {
        return _pushLocalChanges(
          api: api,
          basePath: basePath,
          profileId: profileId,
          localDiff: localDiff,
          localFiles: localFiles,
          deviceId: deviceId,
          currentCommitSha: remote?.commitSha,
        );
      }

      // 8. Only remote changes -> pull
      if (!localDiff.hasChanges && remoteDiff.hasChanges) {
        final tree = fileMapToBookmarkTree(remoteFiles, basePath);
        await _saveSyncState(
          profileId: profileId,
          commitSha: remote!.commitSha,
          shaMap: remote.shaMap,
          fileMap: remoteFiles,
          previousCommitSha: baseCommitSha,
        );
        return SyncResult(
          success: true,
          message: 'Pulled remote changes',
          rootFolders: tree,
          commitSha: remote.commitSha,
          fileMap: remoteFiles,
          shaMap: remote.shaMap,
        );
      }

      // 9. Both changed -> three-way merge
      final mergeResult = mergeDiffs(
        localDiff: localDiff,
        remoteDiff: remoteDiff,
        localFiles: localFiles,
        remoteFiles: remoteFiles,
        baseFiles: baseContentMap,
      );

      debugLog.log('sync: merge conflicts=${mergeResult.conflicts.length}, push=${mergeResult.toPush.length}, apply=${mergeResult.toApplyLocal.length}');

      if (mergeResult.hasConflicts) {
        return SyncResult(
          success: false,
          message: 'Conflicting changes detected',
          hasConflict: true,
        );
      }

      // Apply merge: build merged file map
      final mergedFiles = Map<String, String>.from(localFiles);
      for (final entry in mergeResult.toApplyLocal.entries) {
        if (entry.value == null) {
          mergedFiles.remove(entry.key);
        } else {
          mergedFiles[entry.key] = entry.value!;
        }
      }

      final tree = fileMapToBookmarkTree(mergedFiles, basePath);

      // Push merged changes if needed
      String? newCommitSha = remote?.commitSha;
      if (mergeResult.toPush.isNotEmpty) {
        final msg = _commitMessage('Bookmark merge', deviceId);
        newCommitSha = await api.atomicCommit(msg, mergeResult.toPush);
      }

      await _saveSyncState(
        profileId: profileId,
        commitSha: newCommitSha ?? remote?.commitSha ?? '',
        shaMap: remote?.shaMap ?? {},
        fileMap: mergedFiles,
        previousCommitSha: baseCommitSha,
      );

      return SyncResult(
        success: true,
        message: mergeResult.toPush.isNotEmpty
            ? 'Merged and pushed changes'
            : 'Applied remote changes',
        rootFolders: tree,
        commitSha: newCommitSha,
        fileMap: mergedFiles,
        shaMap: remote?.shaMap ?? {},
      );
    } finally {
      api.close();
    }
  }

  /// Force-pull: overwrite local cache with remote state.
  Future<SyncResult> forcePull({
    required GithubCredentials creds,
    required String profileId,
  }) async {
    final api = _createApi(creds);
    try {
      final basePath = creds.basePath.replaceAll(RegExp(r'/+$'), '');
      final prevCommitSha = _syncState.getLastCommitSha(profileId);

      final remote = await fetchRemoteFileMap(api, basePath);
      if (remote == null || remote.fileMap.isEmpty) {
        return SyncResult(
          success: false,
          message: 'No bookmarks found on GitHub',
        );
      }

      final tree = fileMapToBookmarkTree(remote.fileMap, basePath);
      await _saveSyncState(
        profileId: profileId,
        commitSha: remote.commitSha,
        shaMap: remote.shaMap,
        fileMap: remote.fileMap,
        previousCommitSha: prevCommitSha,
      );

      return SyncResult(
        success: true,
        message: 'Pulled from GitHub',
        rootFolders: tree,
        commitSha: remote.commitSha,
        fileMap: remote.fileMap,
        shaMap: remote.shaMap,
      );
    } finally {
      api.close();
    }
  }

  /// Force-push: overwrite remote with the current cached tree.
  Future<SyncResult> forcePush({
    required GithubCredentials creds,
    required String profileId,
    required List<BookmarkFolder> cachedTree,
    String? deviceId,
  }) async {
    final api = _createApi(creds);
    try {
      final basePath = creds.basePath.replaceAll(RegExp(r'/+$'), '');
      final localFiles = bookmarkTreeToFileMap(cachedTree, basePath);

      // Fetch remote to determine deletions
      final remote = await fetchRemoteFileMap(api, basePath);
      final remoteFiles = remote?.fileMap ?? {};

      final fileChanges = <String, String?>{};
      for (final entry in localFiles.entries) {
        if (remoteFiles[entry.key] != entry.value) {
          fileChanges[entry.key] = entry.value;
        }
      }
      for (final path in remoteFiles.keys) {
        if (!localFiles.containsKey(path) &&
            !isGeneratedOrSettingsPath(path)) {
          fileChanges[path] = null;
        }
      }

      if (fileChanges.isEmpty) {
        return SyncResult(
          success: true,
          message: 'Everything is in sync',
          rootFolders: cachedTree,
          commitSha: remote?.commitSha,
          fileMap: localFiles,
          shaMap: remote?.shaMap ?? {},
        );
      }

      final msg = _commitMessage('Bookmark sync (push)', deviceId);
      final newCommitSha = await api.atomicCommit(msg, fileChanges);

      // Re-fetch to get accurate SHA map
      final freshRemote = await fetchRemoteFileMap(api, basePath);
      await _saveSyncState(
        profileId: profileId,
        commitSha: freshRemote?.commitSha ?? newCommitSha,
        shaMap: freshRemote?.shaMap ?? {},
        fileMap: localFiles,
      );

      return SyncResult(
        success: true,
        message: 'Pushed to GitHub',
        rootFolders: cachedTree,
        commitSha: newCommitSha,
        fileMap: localFiles,
        shaMap: freshRemote?.shaMap ?? {},
      );
    } finally {
      api.close();
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<SyncResult> _handleFirstSync({
    required GitDataApi api,
    required GithubCredentials creds,
    required String profileId,
    required String basePath,
    required List<BookmarkFolder> cachedTree,
    required RemoteFileMapResult? remote,
    String? deviceId,
  }) async {
    final hasRemote =
        remote != null && _hasBookmarkPayload(remote.fileMap);
    final localFiles = bookmarkTreeToFileMap(cachedTree, basePath);
    final hasLocal = _hasBookmarkPayload(localFiles);

    if (!hasRemote && hasLocal) {
      // Push local to empty remote
      final msg = _commitMessage('Initial bookmark sync', deviceId);
      final sha = await api.atomicCommit(msg, localFiles.cast<String, String?>());
      final freshRemote = await fetchRemoteFileMap(api, basePath);
      await _saveSyncState(
        profileId: profileId,
        commitSha: freshRemote?.commitSha ?? sha,
        shaMap: freshRemote?.shaMap ?? {},
        fileMap: localFiles,
      );
      return SyncResult(
        success: true,
        message: 'Pushed local bookmarks to GitHub',
        rootFolders: cachedTree,
        commitSha: sha,
        fileMap: localFiles,
        shaMap: freshRemote?.shaMap ?? {},
      );
    }

    if (hasRemote && !hasLocal) {
      // Pull remote to empty local
      final tree = fileMapToBookmarkTree(remote.fileMap, basePath);
      await _saveSyncState(
        profileId: profileId,
        commitSha: remote.commitSha,
        shaMap: remote.shaMap,
        fileMap: remote.fileMap,
      );
      return SyncResult(
        success: true,
        message: 'Pulled bookmarks from GitHub',
        rootFolders: tree,
        commitSha: remote.commitSha,
        fileMap: remote.fileMap,
        shaMap: remote.shaMap,
      );
    }

    if (hasRemote && hasLocal) {
      // Both have data but no base — conflict
      return SyncResult(
        success: false,
        message: 'Both local and remote have bookmarks. Use force push or pull to resolve.',
        hasConflict: true,
      );
    }

    // Neither has data
    return SyncResult(
      success: true,
      message: 'No bookmarks to sync',
      rootFolders: [],
      commitSha: remote?.commitSha,
      fileMap: {},
      shaMap: {},
    );
  }

  Future<SyncResult> _pushLocalChanges({
    required GitDataApi api,
    required String basePath,
    required String profileId,
    required DiffResult localDiff,
    required Map<String, String> localFiles,
    String? deviceId,
    String? currentCommitSha,
  }) async {
    final fileChanges = <String, String?>{};
    for (final entry in localDiff.added.entries) {
      fileChanges[entry.key] = entry.value;
    }
    for (final entry in localDiff.modified.entries) {
      fileChanges[entry.key] = entry.value;
    }
    for (final path in localDiff.removed) {
      fileChanges[path] = null;
    }

    final msg = _commitMessage('Bookmark sync', deviceId);
    final newSha = await api.atomicCommit(msg, fileChanges);

    final freshRemote = await fetchRemoteFileMap(api, basePath);
    await _saveSyncState(
      profileId: profileId,
      commitSha: freshRemote?.commitSha ?? newSha,
      shaMap: freshRemote?.shaMap ?? {},
      fileMap: localFiles,
      previousCommitSha: currentCommitSha,
    );

    final tree = fileMapToBookmarkTree(localFiles, basePath);
    return SyncResult(
      success: true,
      message: 'Pushed local changes',
      rootFolders: tree,
      commitSha: newSha,
      fileMap: localFiles,
      shaMap: freshRemote?.shaMap ?? {},
    );
  }

  Future<void> _saveSyncState({
    required String profileId,
    required String commitSha,
    required Map<String, String> shaMap,
    required Map<String, String> fileMap,
    String? previousCommitSha,
  }) async {
    await _syncState.saveSyncState(
      profileId: profileId,
      commitSha: commitSha,
      shaMap: shaMap,
      fileMap: fileMap,
      previousCommitSha: previousCommitSha,
    );
  }

  bool _hasBookmarkPayload(Map<String, String> files) {
    return files.keys.any((path) {
      if (!path.endsWith('.json')) return false;
      if (path.endsWith('/_index.json') || path.endsWith('/_order.json')) {
        return false;
      }
      if (isGeneratedOrSettingsPath(path)) return false;
      return true;
    });
  }

  String _commitMessage(String prefix, String? deviceId) {
    final device = deviceId != null && deviceId.length >= 8
        ? deviceId.substring(0, 8)
        : (deviceId ?? 'app');
    return '$prefix from $device — ${DateTime.now().toUtc().toIso8601String()}';
  }

  GitDataApi _createApi(GithubCredentials creds) => GitDataApi(
        token: creds.token,
        owner: creds.owner,
        repo: creds.repo,
        branch: creds.branch,
      );
}
