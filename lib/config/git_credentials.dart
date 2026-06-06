import 'git_provider_caps.dart';

/// Git repository credentials (extension-compatible profile fields).
class GitCredentials {
  GitCredentials({
    required String token,
    required this.owner,
    required this.repo,
    required this.branch,
    this.basePath = 'bookmarks',
    this.gitProvider = GitProviders.github,
    this.serverUrl = '',
  }) : token = token.trim();

  factory GitCredentials.fromJson(Map<String, dynamic> json) {
    return GitCredentials(
      token: (json['token'] as String?) ??
          (json['githubToken'] as String?) ??
          '',
      owner: (json['owner'] as String?) ??
          (json['repoOwner'] as String?) ??
          '',
      repo: (json['repo'] as String?) ??
          (json['repoName'] as String?) ??
          '',
      branch: (json['branch'] as String?) ?? 'main',
      basePath: (json['filePath'] as String?) ??
          (json['basePath'] as String?) ??
          'bookmarks',
      gitProvider: (json['gitProvider'] as String?) ?? GitProviders.github,
      serverUrl: (json['serverUrl'] as String?) ?? '',
    );
  }

  final String token;
  final String owner;
  final String repo;
  final String branch;
  final String basePath;
  final String gitProvider;
  final String serverUrl;

  GitProviderCaps get caps => getProviderCaps(gitProvider);

  bool get isValid =>
      token.isNotEmpty &&
      owner.isNotEmpty &&
      repo.isNotEmpty &&
      branch.isNotEmpty &&
      _serverUrlValid;

  bool get _serverUrlValid {
    if (!caps.requireServerUrl) return true;
    return resolveEffectiveServerUrl(gitProvider, serverUrl).isNotEmpty;
  }

  /// Cache key for bookmark storage (provider|owner|repo|branch|basePath).
  String get cacheKey =>
      '$gitProvider|$owner|$repo|$branch|$basePath';

  Map<String, dynamic> toJson() => {
        'token': token,
        'owner': owner,
        'repo': repo,
        'branch': branch,
        'filePath': basePath,
        'gitProvider': gitProvider,
        if (serverUrl.isNotEmpty) 'serverUrl': serverUrl,
      };

  GitCredentials copyWith({
    String? token,
    String? owner,
    String? repo,
    String? branch,
    String? basePath,
    String? gitProvider,
    String? serverUrl,
  }) {
    return GitCredentials(
      token: token ?? this.token,
      owner: owner ?? this.owner,
      repo: repo ?? this.repo,
      branch: branch ?? this.branch,
      basePath: basePath ?? this.basePath,
      gitProvider: gitProvider ?? this.gitProvider,
      serverUrl: serverUrl ?? this.serverUrl,
    );
  }
}
