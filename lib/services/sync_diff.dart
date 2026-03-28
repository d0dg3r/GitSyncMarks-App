import 'dart:convert';

import 'remote_fetch.dart';

/// Result of computing a diff between two file maps.
class DiffResult {
  DiffResult({
    required this.added,
    required this.removed,
    required this.modified,
  });

  /// path -> content for files present in current but not in base
  final Map<String, String> added;

  /// paths present in base but not in current
  final List<String> removed;

  /// path -> content for files present in both but with different content
  final Map<String, String> modified;

  bool get hasChanges =>
      added.isNotEmpty || removed.isNotEmpty || modified.isNotEmpty;
}

/// A conflict where both local and remote changed the same file differently.
class ConflictEntry {
  ConflictEntry({required this.path, this.local, this.remote});

  final String path;
  final String? local;
  final String? remote;
}

/// Result of merging two diffs.
class MergeResult {
  MergeResult({
    required this.toPush,
    required this.toApplyLocal,
    required this.conflicts,
  });

  /// path -> content (null = delete) to push to GitHub
  final Map<String, String?> toPush;

  /// path -> content (null = delete) to apply locally
  final Map<String, String?> toApplyLocal;

  final List<ConflictEntry> conflicts;

  bool get hasConflicts => conflicts.isNotEmpty;
}

/// Compute the diff between a base file map and a current file map.
///
/// Both maps should already be filtered (via [filterForDiff]) to exclude
/// generated and settings files.
DiffResult computeDiff(Map<String, String> base, Map<String, String> current) {
  final added = <String, String>{};
  final removed = <String>[];
  final modified = <String, String>{};

  for (final entry in current.entries) {
    if (!base.containsKey(entry.key)) {
      added[entry.key] = entry.value;
    } else if (base[entry.key] != entry.value) {
      modified[entry.key] = entry.value;
    }
  }

  for (final path in base.keys) {
    if (!current.containsKey(path)) {
      removed.add(path);
    }
  }

  return DiffResult(added: added, removed: removed, modified: modified);
}

/// Three-way merge for `_order.json` arrays.
///
/// Keeps local ordering as the base, applies remote additions at the end, and
/// honours removals from both sides. Returns the merged JSON string, or `null`
/// when the merge cannot be performed (malformed input).
String? mergeOrderJson(
  String? baseContent,
  String localContent,
  String remoteContent,
) {
  List<dynamic> base, local, remote;
  try {
    base = baseContent != null ? json.decode(baseContent) as List : [];
    local = json.decode(localContent) as List;
    remote = json.decode(remoteContent) as List;
  } catch (_) {
    return null;
  }

  final baseKeys = base.map(_orderEntryKey).toSet();
  final localKeys = local.map(_orderEntryKey).toSet();
  final remoteKeys = remote.map(_orderEntryKey).toSet();

  final remoteRemovedKeys = base
      .where((e) => !remoteKeys.contains(_orderEntryKey(e)))
      .map(_orderEntryKey)
      .toSet();
  final localRemovedKeys = base
      .where((e) => !localKeys.contains(_orderEntryKey(e)))
      .map(_orderEntryKey)
      .toSet();

  // Start with local order, remove entries that remote deleted
  final merged =
      local.where((e) => !remoteRemovedKeys.contains(_orderEntryKey(e))).toList();

  // Append entries that remote added (not in base, not already merged, not locally removed)
  final mergedKeys = merged.map(_orderEntryKey).toSet();
  for (final entry in remote) {
    final key = _orderEntryKey(entry);
    if (!baseKeys.contains(key) &&
        !mergedKeys.contains(key) &&
        !localRemovedKeys.contains(key)) {
      merged.add(entry);
      mergedKeys.add(key);
    }
  }

  // Stable dedupe
  final deduped = <dynamic>[];
  final finalKeys = <String>{};
  for (final entry in merged) {
    final key = _orderEntryKey(entry);
    if (!finalKeys.contains(key)) {
      deduped.add(entry);
      finalKeys.add(key);
    }
  }

  return const JsonEncoder.withIndent('  ').convert(deduped);
}

/// Merge local and remote diffs into push/apply/conflict sets.
///
/// For `_order.json` files changed on both sides, a content-level merge is
/// attempted before falling back to conflict.
MergeResult mergeDiffs({
  required DiffResult localDiff,
  required DiffResult remoteDiff,
  required Map<String, String> localFiles,
  required Map<String, String> remoteFiles,
  Map<String, String> baseFiles = const {},
}) {
  final toPush = <String, String?>{};
  final toApplyLocal = <String, String?>{};
  final conflicts = <ConflictEntry>[];

  final allPaths = <String>{
    ...localDiff.added.keys,
    ...localDiff.removed,
    ...localDiff.modified.keys,
    ...remoteDiff.added.keys,
    ...remoteDiff.removed,
    ...remoteDiff.modified.keys,
  };

  for (final path in allPaths) {
    final localAdded = localDiff.added.containsKey(path);
    final localRemoved = localDiff.removed.contains(path);
    final localModified = localDiff.modified.containsKey(path);
    final remoteAdded = remoteDiff.added.containsKey(path);
    final remoteRemoved = remoteDiff.removed.contains(path);
    final remoteModified = remoteDiff.modified.containsKey(path);

    final localChanged = localAdded || localRemoved || localModified;
    final remoteChanged = remoteAdded || remoteRemoved || remoteModified;

    if (localChanged && !remoteChanged) {
      toPush[path] = localRemoved ? null : localFiles[path];
    } else if (!localChanged && remoteChanged) {
      toApplyLocal[path] = remoteRemoved ? null : remoteFiles[path];
    } else if (localChanged && remoteChanged) {
      final localContent = localRemoved ? null : localFiles[path];
      final remoteContent = remoteRemoved ? null : remoteFiles[path];

      if (localContent == remoteContent) continue;

      // Attempt _order.json merge
      if (path.endsWith('/_order.json') &&
          localContent != null &&
          remoteContent != null) {
        final merged =
            mergeOrderJson(baseFiles[path], localContent, remoteContent);
        if (merged != null) {
          toPush[path] = merged;
          toApplyLocal[path] = merged;
          continue;
        }
      }

      if (localRemoved && remoteRemoved) continue;

      conflicts
          .add(ConflictEntry(path: path, local: localContent, remote: remoteContent));
    }
  }

  return MergeResult(
    toPush: toPush,
    toApplyLocal: toApplyLocal,
    conflicts: conflicts,
  );
}

String _orderEntryKey(dynamic entry) {
  if (entry is String) return entry;
  if (entry is Map && entry['dir'] != null) return 'dir:${entry['dir']}';
  return json.encode(entry);
}
