import 'git_provider.dart';
import 'providers/gitea_provider.dart';

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

/// Result of fetching the remote file map from a Git provider.
class RemoteFileMapResult {
  RemoteFileMapResult({
    required this.shaMap,
    required this.fileMap,
    required this.commitSha,
  });

  final Map<String, String> shaMap;
  final Map<String, String> fileMap;
  final String commitSha;
}

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

bool isGeneratedOrSettingsPath(String path) {
  if (diffIgnoreSuffixes.any((s) => path.endsWith(s))) return true;
  if (settingsEncPattern.hasMatch(path)) return true;
  return false;
}

Map<String, String> filterForDiff(Map<String, String> files) {
  final out = <String, String>{};
  for (final entry in files.entries) {
    if (!isGeneratedOrSettingsPath(entry.key)) {
      out[entry.key] = entry.value;
    }
  }
  return out;
}

Future<({List<TreeEntry> tree, bool truncated})> fetchTreeEntriesForCommit(
  GitProviderClient api,
  String commitSha,
) async {
  if (api is GiteaProvider) {
    final direct = await api.getRecursiveTreeForCommit(commitSha);
    if (direct != null) {
      return (tree: direct.tree, truncated: direct.truncated);
    }
  }
  final treeSha = await api.getCommitTreeSha(commitSha);
  final tree = await api.getTree(treeSha);
  return (tree: tree, truncated: false);
}

Future<({Map<String, String> shaMap, Map<String, String> fileMap})>
    buildRemoteMaps(
  GitProviderClient api,
  String basePath,
  Map<String, SyncFileEntry>? baseFiles,
  String commitSha,
) async {
  Future<({Map<String, String> shaMap, Map<String, String> fileMap})>
      loadViaContents(Object? primaryErr) async {
    if (api is! GiteaProvider) {
      if (primaryErr != null) {
        if (primaryErr is GitProviderException) throw primaryErr;
        throw GitProviderException(primaryErr.toString(), statusCode: 422);
      }
      return (shaMap: <String, String>{}, fileMap: <String, String>{});
    }

    try {
      final result =
          await api.fetchFileMapViaContents(basePath, commitSha);
      return (shaMap: result.shaMap, fileMap: result.fileMap);
    } catch (contentsErr) {
      final primaryMsg = primaryErr?.toString() ?? 'tree read unavailable';
      final contentsMsg = contentsErr.toString();
      final statusCode = contentsErr is GitProviderException
          ? contentsErr.statusCode
          : primaryErr is GitProviderException
              ? primaryErr.statusCode
              : 422;
      throw GitProviderException(
        'Remote read failed (tree: $primaryMsg; contents: $contentsMsg)',
        statusCode: statusCode,
      );
    }
  }

  try {
    final treeResult = await fetchTreeEntriesForCommit(api, commitSha);
    if (treeResult.truncated) {
      throw GitProviderException(
        'Git tree listing truncated — repo too large for safe sync',
        statusCode: 422,
      );
    }
    final shaMap = gitTreeToShaMap(treeResult.tree, basePath);
    if (shaMap.isEmpty) {
      if (api is GiteaProvider) {
        return loadViaContents(
          GitProviderException(
            'Git tree listing empty under base path',
            statusCode: 422,
          ),
        );
      }
      return (shaMap: <String, String>{}, fileMap: <String, String>{});
    }
    final pairs = shaMap.entries.map((e) => MapEntry(e.key, e.value)).toList();
    final fileMap = await api.fetchBlobsBatched(pairs, baseFiles: baseFiles);
    return (shaMap: shaMap, fileMap: fileMap);
  } catch (err) {
    return loadViaContents(err);
  }
}

Future<RemoteFileMapResult?> fetchRemoteFileMap(
  GitProviderClient api,
  String basePath, {
  Map<String, SyncFileEntry>? baseFiles,
  String? providerId,
}) async {
  final commitSha = await api.getLatestCommitSha();
  if (commitSha == null) return null;

  final maps = await buildRemoteMaps(api, basePath, baseFiles, commitSha);

  return RemoteFileMapResult(
    shaMap: maps.shaMap,
    fileMap: maps.fileMap,
    commitSha: commitSha,
  );
}

Future<RemoteFileMapResult> fetchRemoteFileMapAtCommit(
  GitProviderClient api,
  String basePath,
  String commitSha, {
  String? providerId,
}) async {
  final maps = await buildRemoteMaps(api, basePath, null, commitSha);

  return RemoteFileMapResult(
    shaMap: maps.shaMap,
    fileMap: maps.fileMap,
    commitSha: commitSha,
  );
}
