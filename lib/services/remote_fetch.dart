import '../config/git_provider_caps.dart';
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

Future<RemoteFileMapResult?> fetchRemoteFileMap(
  GitProviderClient api,
  String basePath, {
  Map<String, SyncFileEntry>? baseFiles,
  String? providerId,
}) async {
  final pid = providerId ?? api.providerId;

  if (usesContentsApiReads(pid)) {
    return _fetchViaContents(api as GiteaProvider, basePath, baseFiles);
  }

  final commitSha = await api.getLatestCommitSha();
  if (commitSha == null) return null;

  final commit = await api.getCommit(commitSha);
  final treeSha = await api.getCommitTreeSha(commit.sha);
  final treeEntries = await api.getTree(treeSha);
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

Future<RemoteFileMapResult?> _fetchViaContents(
  GiteaProvider api,
  String basePath,
  Map<String, SyncFileEntry>? baseFiles,
) async {
  final commitSha = await api.getLatestCommitSha();
  if (commitSha == null) return null;

  final result = await api.fetchFileMapViaContents(basePath, commitSha);
  final fileMap = <String, String>{};

  for (final entry in result.fileMap.entries) {
    final base = baseFiles?[entry.key];
    final sha = result.shaMap[entry.key];
    if (base != null && sha != null && base.sha == sha) {
      fileMap[entry.key] = base.content;
    } else {
      fileMap[entry.key] = entry.value;
    }
  }

  return RemoteFileMapResult(
    shaMap: result.shaMap,
    fileMap: fileMap,
    commitSha: commitSha,
  );
}

Future<RemoteFileMapResult> fetchRemoteFileMapAtCommit(
  GitProviderClient api,
  String basePath,
  String commitSha, {
  String? providerId,
}) async {
  final pid = providerId ?? api.providerId;

  if (usesContentsApiReads(pid)) {
    final gitea = api as GiteaProvider;
    final result = await gitea.fetchFileMapViaContents(basePath, commitSha);
    return RemoteFileMapResult(
      shaMap: result.shaMap,
      fileMap: result.fileMap,
      commitSha: commitSha,
    );
  }

  final commit = await api.getCommit(commitSha);
  final treeSha = await api.getCommitTreeSha(commit.sha);
  final treeEntries = await api.getTree(treeSha);
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
