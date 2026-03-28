import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import 'git_data_api.dart';

const _boxName = 'sync_state';

/// Persists per-profile sync state for three-way merge and history.
class SyncStateService {
  SyncStateService();

  Box<dynamic> get _box => Hive.box(_boxName);

  String _key(String profileId, String field) => '${profileId}_$field';

  /// Saves the sync state snapshot after a successful sync.
  Future<void> saveSyncState({
    required String profileId,
    required String commitSha,
    required Map<String, String> shaMap,
    required Map<String, String> fileMap,
    String? previousCommitSha,
  }) async {
    await _box.put(_key(profileId, 'commitSha'), commitSha);
    await _box.put(_key(profileId, 'shaMap'), json.encode(shaMap));

    final syncFiles = <String, Map<String, dynamic>>{};
    for (final entry in fileMap.entries) {
      final sha = shaMap[entry.key] ?? '';
      syncFiles[entry.key] = {'sha': sha, 'content': entry.value};
    }
    await _box.put(_key(profileId, 'syncFiles'), json.encode(syncFiles));

    if (previousCommitSha != null) {
      await _box.put(
          _key(profileId, 'previousCommitSha'), previousCommitSha);
    }
  }

  /// Returns the last synced commit SHA.
  String? getLastCommitSha(String profileId) {
    return _box.get(_key(profileId, 'commitSha')) as String?;
  }

  /// Returns the commit SHA from before the last sync (for undo).
  String? getPreviousCommitSha(String profileId) {
    return _box.get(_key(profileId, 'previousCommitSha')) as String?;
  }

  /// Returns the last synced sha map (path -> blob SHA).
  Map<String, String> getLastShaMap(String profileId) {
    final raw = _box.get(_key(profileId, 'shaMap')) as String?;
    if (raw == null) return {};
    try {
      final decoded = json.decode(raw);
      if (decoded is Map) {
        return decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
      }
    } catch (_) {}
    return {};
  }

  /// Returns the last synced file entries (path -> SyncFileEntry).
  Map<String, SyncFileEntry> getLastSyncFiles(String profileId) {
    final raw = _box.get(_key(profileId, 'syncFiles')) as String?;
    if (raw == null) return {};
    try {
      final decoded = json.decode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) {
        final m = v as Map<String, dynamic>;
        return MapEntry(k, SyncFileEntry.fromJson(m));
      });
    } catch (_) {}
    return {};
  }

  /// Clears all sync state (used by factory reset).
  Future<void> clearAll() async {
    await _box.clear();
  }

  /// Clears sync state for a specific profile.
  Future<void> clearProfile(String profileId) async {
    for (final field in ['commitSha', 'shaMap', 'syncFiles', 'previousCommitSha']) {
      await _box.delete(_key(profileId, field));
    }
  }
}
