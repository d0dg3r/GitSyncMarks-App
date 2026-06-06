/// Git provider IDs (extension-compatible).
class GitProviders {
  static const github = 'github';
  static const gitea = 'gitea';
  static const forgejo = 'forgejo';
  static const codeberg = 'codeberg';
  static const gogs = 'gogs';
  static const gitlab = 'gitlab';

  static const supported = [
    github,
    gitlab,
    codeberg,
    gitea,
    forgejo,
    gogs,
  ];
}

enum GitWriteStrategy { tree, contents, gitlabCommits }

enum GitSelfHostedMode { optional, required, fixed }

class GitProviderCaps {
  const GitProviderCaps({
    required this.adapter,
    required this.apiPath,
    this.defaultApiBase,
    required this.authScheme,
    required this.selfHosted,
    required this.requireServerUrl,
    required this.subgroups,
    required this.writeStrategy,
    required this.commitUrlInfix,
    this.defaultWebBase,
    required this.repoFolderPrefix,
    this.defaultServerUrl = '',
  });

  final String adapter;
  final String apiPath;
  final String? defaultApiBase;
  final String authScheme;
  final GitSelfHostedMode selfHosted;
  final bool requireServerUrl;
  final bool subgroups;
  final GitWriteStrategy writeStrategy;
  final String commitUrlInfix;
  final String? defaultWebBase;
  final String repoFolderPrefix;
  final String defaultServerUrl;
}

const Map<String, GitProviderCaps> providerCaps = {
  GitProviders.github: GitProviderCaps(
    adapter: 'github',
    apiPath: '/api/v3',
    defaultApiBase: 'https://api.github.com',
    authScheme: 'Bearer',
    selfHosted: GitSelfHostedMode.optional,
    requireServerUrl: false,
    subgroups: false,
    writeStrategy: GitWriteStrategy.tree,
    commitUrlInfix: '/commit/',
    defaultWebBase: 'https://github.com',
    repoFolderPrefix: 'GitHubRepos',
  ),
  GitProviders.gitea: GitProviderCaps(
    adapter: 'gitea',
    apiPath: '/api/v1',
    authScheme: 'token',
    selfHosted: GitSelfHostedMode.required,
    requireServerUrl: true,
    subgroups: false,
    writeStrategy: GitWriteStrategy.contents,
    commitUrlInfix: '/commit/',
    repoFolderPrefix: 'GiteaRepos',
  ),
  GitProviders.forgejo: GitProviderCaps(
    adapter: 'gitea',
    apiPath: '/api/v1',
    authScheme: 'token',
    selfHosted: GitSelfHostedMode.required,
    requireServerUrl: true,
    subgroups: false,
    writeStrategy: GitWriteStrategy.contents,
    commitUrlInfix: '/commit/',
    repoFolderPrefix: 'ForgejoRepos',
  ),
  GitProviders.codeberg: GitProviderCaps(
    adapter: 'gitea',
    apiPath: '/api/v1',
    defaultApiBase: 'https://codeberg.org/api/v1',
    authScheme: 'token',
    selfHosted: GitSelfHostedMode.fixed,
    requireServerUrl: false,
    subgroups: false,
    writeStrategy: GitWriteStrategy.contents,
    commitUrlInfix: '/commit/',
    defaultWebBase: 'https://codeberg.org',
    repoFolderPrefix: 'CodebergRepos',
    defaultServerUrl: 'https://codeberg.org',
  ),
  GitProviders.gogs: GitProviderCaps(
    adapter: 'gitea',
    apiPath: '/api/v1',
    authScheme: 'token',
    selfHosted: GitSelfHostedMode.required,
    requireServerUrl: true,
    subgroups: false,
    writeStrategy: GitWriteStrategy.contents,
    commitUrlInfix: '/commit/',
    repoFolderPrefix: 'GogsRepos',
  ),
  GitProviders.gitlab: GitProviderCaps(
    adapter: 'gitlab',
    apiPath: '/api/v4',
    defaultApiBase: 'https://gitlab.com/api/v4',
    authScheme: 'Bearer',
    selfHosted: GitSelfHostedMode.optional,
    requireServerUrl: false,
    subgroups: true,
    writeStrategy: GitWriteStrategy.gitlabCommits,
    commitUrlInfix: '/-/commit/',
    defaultWebBase: 'https://gitlab.com',
    repoFolderPrefix: 'GitLabRepos',
  ),
};

GitProviderCaps getProviderCaps([String? providerId]) {
  final id = providerId?.trim().isNotEmpty == true
      ? providerId!.trim()
      : GitProviders.github;
  return providerCaps[id] ?? providerCaps[GitProviders.github]!;
}

bool usesContentsApiReads(String providerId) {
  return getProviderCaps(providerId).writeStrategy == GitWriteStrategy.contents;
}

String normalizeServerUrl(String url) {
  var trimmed = url.trim();
  if (trimmed.isEmpty) return '';
  if (!trimmed.startsWith(RegExp(r'https?://', caseSensitive: false))) {
    trimmed = 'https://$trimmed';
  }
  try {
    final parsed = Uri.parse(trimmed);
    var path = parsed.path.replaceAll(RegExp(r'/+$'), '');
    for (final suffix in ['/api/v4', '/api/v3', '/api/v1']) {
      if (path.endsWith(suffix)) {
        path = path.substring(0, path.length - suffix.length);
        break;
      }
    }
    final origin = parsed.origin;
    return path.isEmpty ? origin : '$origin$path';
  } catch (_) {
    return trimmed
        .replaceAll(RegExp(r'/+$'), '')
        .replaceAll(RegExp(r'/api/v[134]$'), '');
  }
}

String resolveEffectiveServerUrl(String providerId, String serverUrl) {
  final caps = getProviderCaps(providerId);
  final normalized = normalizeServerUrl(serverUrl);
  if (normalized.isNotEmpty) return normalized;
  return caps.defaultServerUrl;
}

String resolveApiBase(String providerId, String serverUrl) {
  final caps = getProviderCaps(providerId);
  final normalized = resolveEffectiveServerUrl(providerId, serverUrl);

  if (caps.defaultApiBase != null && normalized.isEmpty) {
    return caps.defaultApiBase!;
  }

  if (caps.adapter == 'gitea') {
    if (normalized.isEmpty) {
      throw GitProviderCapsException('$providerId server URL is required');
    }
    return '$normalized${caps.apiPath}';
  }

  if (caps.adapter == 'gitlab') {
    if (normalized.isEmpty) {
      return caps.defaultApiBase ?? 'https://gitlab.com/api/v4';
    }
    return '$normalized${caps.apiPath}';
  }

  if (normalized.isNotEmpty) {
    return '$normalized${caps.apiPath}';
  }
  return caps.defaultApiBase ?? 'https://api.github.com';
}

String resolveWebBaseUrl(String providerId, String serverUrl) {
  final caps = getProviderCaps(providerId);
  final normalized = resolveEffectiveServerUrl(providerId, serverUrl);
  if (normalized.isNotEmpty) return normalized;
  return caps.defaultWebBase ?? 'https://github.com';
}

String buildCommitUrl({
  required String providerId,
  String serverUrl = '',
  required String owner,
  required String repo,
  required String commitSha,
}) {
  final caps = getProviderCaps(providerId);
  final webBase = resolveWebBaseUrl(providerId, serverUrl).replaceAll(RegExp(r'/+$'), '');
  return '$webBase/$owner/$repo${caps.commitUrlInfix}$commitSha';
}

class GitProviderCapsException implements Exception {
  GitProviderCapsException(this.message);
  final String message;
  @override
  String toString() => message;
}
