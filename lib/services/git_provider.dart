import '../config/git_credentials.dart';
import 'git_provider_types.dart';
import 'providers/gitea_provider.dart';
import 'providers/github_provider.dart';
import 'providers/gitlab_provider.dart';

export 'git_provider_exception.dart';
export 'git_provider_types.dart';

/// Provider-agnostic Git API client (extension v3.0 contract).
abstract class GitProviderClient {
  String get providerId;
  String get owner;
  String get repo;
  String get branch;
  String get basePath;

  String webBaseUrl();
  String buildCommitUrl(String commitSha);

  Future<String?> getLatestCommitSha();
  Future<CommitInfo> getCommit(String commitSha);
  Future<String> getCommitTreeSha(String commitSha);
  Future<List<TreeEntry>> getTree(String treeSha);
  Future<String> getBlob(String blobSha);
  Future<Map<String, String>> fetchBlobsBatched(
    List<MapEntry<String, String>> pathShaPairs, {
    Map<String, SyncFileEntry>? baseFiles,
  });
  Future<List<CommitEntry>> listCommits({String? path, int perPage = 20});

  Future<String> atomicCommit(
    String message,
    Map<String, String?> fileChanges,
  );

  Future<List<ContentEntry>> listContents(String path);
  Future<String> getFileContent(String path);
  Future<CreateOrUpdateResult> createOrUpdateFile(
    String path,
    String content,
    String message, {
    String? sha,
  });
  Future<void> deleteFile(String path, String sha, String message);
  Future<FileMeta?> getFileMeta(String path);
  Future<String?> getBranchHeadSha();

  Future<bool> checkRepo();
  Future<TokenValidationResult> validateToken();

  void close();
}

GitProviderClient createGitProvider(GitCredentials creds) {
  final caps = creds.caps;
  switch (caps.adapter) {
    case 'gitlab':
      return GitLabProvider(
        providerId: creds.gitProvider,
        token: creds.token,
        owner: creds.owner,
        repo: creds.repo,
        branch: creds.branch,
        serverUrl: creds.serverUrl,
        basePath: creds.basePath,
      );
    case 'gitea':
      return GiteaProvider(
        providerId: creds.gitProvider,
        token: creds.token,
        owner: creds.owner,
        repo: creds.repo,
        branch: creds.branch,
        serverUrl: creds.serverUrl,
        basePath: creds.basePath,
      );
    case 'github':
    default:
      return GithubProvider(
        providerId: creds.gitProvider,
        token: creds.token,
        owner: creds.owner,
        repo: creds.repo,
        branch: creds.branch,
        serverUrl: creds.serverUrl,
        basePath: creds.basePath,
      );
  }
}
