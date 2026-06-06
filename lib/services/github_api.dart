import 'dart:convert';

import '../config/git_credentials.dart';
import 'git_provider.dart';
import 'git_provider_types.dart';

export 'git_provider_exception.dart' show GithubApiException;
export 'git_provider_types.dart'
    show ContentEntry, CreateOrUpdateResult, FileMeta;

/// Contents API client — delegates to [GitProviderClient].
class GithubApi {
  GithubApi({
    required String token,
    required String owner,
    required String repo,
    required String branch,
    String? basePath,
    String gitProvider = 'github',
    String serverUrl = '',
  }) : _provider = createGitProvider(
          GitCredentials(
            token: token,
            owner: owner,
            repo: repo,
            branch: branch,
            basePath: basePath ?? 'bookmarks',
            gitProvider: gitProvider,
            serverUrl: serverUrl,
          ),
        );

  GithubApi.fromProvider(this._provider);

  final GitProviderClient _provider;

  String get owner => _provider.owner;
  String get repo => _provider.repo;
  String get branch => _provider.branch;
  String get basePath => _provider.basePath;

  Future<List<ContentEntry>> getContents(String path) =>
      _provider.listContents(path);

  Future<String> getFileContent(String path) =>
      _provider.getFileContent(path);

  String decodeContent(String base64Content) {
    return utf8.decode(
      base64.decode(base64Content.replaceAll('\n', '')),
    );
  }

  String encodeContent(String content) {
    return base64.encode(utf8.encode(content));
  }

  Future<CreateOrUpdateResult> createOrUpdateFile(
    String path,
    String content,
    String message, {
    String? sha,
  }) =>
      _provider.createOrUpdateFile(path, content, message, sha: sha);

  Future<void> deleteFile(String path, String sha, String message) =>
      _provider.deleteFile(path, sha, message);

  Future<FileMeta?> getFileMeta(String path) => _provider.getFileMeta(path);

  Future<String?> getBranchHeadSha() => _provider.getBranchHeadSha();

  void close() => _provider.close();
}
