import 'git_data_api.dart';

/// Paths that should be excluded from bookmark diffs (generated / metadata).
const List<String> diffIgnoreSuffixes = [
  '/README.md',
  '/_index.json',
  '/bookmarks.html',
  '/feed.xml',
  '/dashy-conf.yml',
];

/// Matches encrypted-settings blobs in the repo.
final RegExp settingsEncPattern = RegExp(
  r'/(?:settings(?:-[^/]+)?\.enc|profiles/[^/]+/settings\.enc)$',
);

/// Result of fetching the remote file map from GitHub.
class RemoteFileMapResult {
  RemoteFileMapResult({
    required this.shaMap,
    required this.fileMap,
    required this.commitSha,
  });

  /// path -> blob SHA
  final Map<String, String> shaMap;

  /// path -> decoded file content
  final Map<String, String> fileMap;

  /// HEAD commit SHA at time of fetch
  final String commitSha;
}

/// Builds a `Map<path, blobSha>` from a recursive Git tree listing,
/// keeping only blobs under [basePath].
Map<String, String> gitTreeToShaMap(List<TreeEntry> entries, String basePath) {
  final base = basePath.endsWith('/') ? basePath : '$basePath/';
  final shaMap = <String, String>{};
  for (final e in entries) {
    if (e.type == 'blob' && e.path.startsWith(base)) {
      shaMap[e.path] = e.sha;
    }
  }
  return shaMap;
}

/// Whether [path] is a generated or settings file that should be excluded
/// from bookmark diffs.
bool isGeneratedOrSettingsPath(String path) {
  if (diffIgnoreSuffixes.any((s) => path.endsWith(s))) return true;
  if (settingsEncPattern.hasMatch(path)) return true;
  return false;
}

/// Filters a file map to only files relevant for bookmark diffs.
Map<String, String> filterForDiff(Map<String, String> files) {
  final out = <String, String>{};
  for (final entry in files.entries) {
    if (!isGeneratedOrSettingsPath(entry.key)) {
      out[entry.key] = entry.value;
    }
  }
  return out;
}

/// Fetches the remote file map at the current HEAD of [basePath].
///
/// [baseFiles] allows reusing previously fetched content when blob SHAs match,
/// avoiding redundant blob downloads.
///
/// Returns `null` when the repo/branch does not exist yet (empty repo).
Future<RemoteFileMapResult?> fetchRemoteFileMap(
  GitDataApi api,
  String basePath, {
  Map<String, SyncFileEntry>? baseFiles,
}) async {
  final commitSha = await api.getLatestCommitSha();
  if (commitSha == null) return null;

  final commit = await api.getCommit(commitSha);
  final treeEntries = await api.getTree(commit.treeSha);
  final shaMap = gitTreeToShaMap(treeEntries, basePath);

  if (shaMap.isEmpty) {
    return RemoteFileMapResult(
      shaMap: {},
      fileMap: {},
      commitSha: commitSha,
    );
  }

  final pairs = shaMap.entries.map((e) => MapEntry(e.key, e.value)).toList();
  final fileMap = await api.fetchBlobsBatched(pairs, baseFiles: baseFiles);

  return RemoteFileMapResult(
    shaMap: shaMap,
    fileMap: fileMap,
    commitSha: commitSha,
  );
}

/// Fetches the remote file map at a specific commit (for history preview/restore).
Future<RemoteFileMapResult> fetchRemoteFileMapAtCommit(
  GitDataApi api,
  String basePath,
  String commitSha,
) async {
  final commit = await api.getCommit(commitSha);
  final treeEntries = await api.getTree(commit.treeSha);
  final shaMap = gitTreeToShaMap(treeEntries, basePath);

  if (shaMap.isEmpty) {
    return RemoteFileMapResult(
      shaMap: {},
      fileMap: {},
      commitSha: commitSha,
    );
  }

  final pairs = shaMap.entries.map((e) => MapEntry(e.key, e.value)).toList();
  final fileMap = await api.fetchBlobsBatched(pairs);

  return RemoteFileMapResult(
    shaMap: shaMap,
    fileMap: fileMap,
    commitSha: commitSha,
  );
}
