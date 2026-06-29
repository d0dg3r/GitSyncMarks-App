import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/git_provider_caps.dart';

const _reposPerPage = 100;

class GitProviderRepo {
  const GitProviderRepo({
    required this.fullName,
    required this.htmlUrl,
    required this.isPrivate,
    this.description,
    this.language,
    this.stargazersCount = 0,
    this.updatedAt,
  });

  final String fullName;
  final String htmlUrl;
  final bool isPrivate;
  final String? description;
  final String? language;
  final int stargazersCount;
  final DateTime? updatedAt;
}

/// Lists repositories for the authenticated user across Git providers.
class GitProviderReposService {
  GitProviderReposService({
    required this.token,
    required this.gitProvider,
    this.serverUrl = '',
    http.Client? client,
  }) : _client = client ?? http.Client(),
       _apiBase = resolveApiBase(gitProvider, serverUrl);

  final String token;
  final String gitProvider;
  final String serverUrl;
  final String _apiBase;
  final http.Client _client;

  Map<String, String> get _headers => {
        'Authorization': 'token $token',
        'Accept': 'application/json',
      };

  void close() => _client.close();

  Future<String> fetchCurrentUser() async {
    switch (getProviderCaps(gitProvider).adapter) {
      case 'gitlab':
        return _fetchGitLabUser();
      case 'gitea':
      case 'github':
      default:
        return _fetchGitHubStyleUser();
    }
  }

  Future<List<GitProviderRepo>> fetchUserRepos() async {
    switch (getProviderCaps(gitProvider).adapter) {
      case 'gitlab':
        return _fetchGitLabRepos();
      case 'gitea':
      case 'github':
      default:
        return _fetchGitHubStyleRepos();
    }
  }

  Future<String> _fetchGitHubStyleUser() async {
    final res = await _client.get(
      Uri.parse('$_apiBase/user'),
      headers: _headers,
    );
    if (res.statusCode != 200) {
      throw Exception('API error: ${res.statusCode}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return (data['login'] as String?) ??
        (data['username'] as String?) ??
        '';
  }

  Future<String> _fetchGitLabUser() async {
    final res = await _client.get(
      Uri.parse('$_apiBase/user'),
      headers: _headers,
    );
    if (res.statusCode != 200) {
      throw Exception('API error: ${res.statusCode}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return (data['username'] as String?) ?? (data['name'] as String?) ?? '';
  }

  Future<List<GitProviderRepo>> _fetchGitHubStyleRepos() async {
    final all = <GitProviderRepo>[];
    var page = 1;

    while (true) {
      final res = await _client.get(
        Uri.parse(
          '$_apiBase/user/repos?per_page=$_reposPerPage&type=all&sort=updated&page=$page',
        ),
        headers: _headers,
      );
      if (res.statusCode != 200) {
        throw Exception('API error: ${res.statusCode}');
      }
      final data = jsonDecode(res.body) as List;
      if (data.isEmpty) break;

      for (final r in data) {
        final m = r as Map<String, dynamic>;
        all.add(GitProviderRepo(
          fullName: (m['full_name'] as String?) ?? '',
          htmlUrl: (m['html_url'] as String?) ??
              '${resolveWebBaseUrl(gitProvider, serverUrl)}/${m['full_name']}',
          isPrivate: m['private'] == true,
          description: m['description'] as String?,
          language: m['language'] as String?,
          stargazersCount: (m['stargazers_count'] as int?) ?? 0,
          updatedAt: m['updated_at'] != null
              ? DateTime.tryParse(m['updated_at'] as String)
              : null,
        ));
      }

      if (data.length < _reposPerPage) break;
      page++;
    }
    return all;
  }

  Future<List<GitProviderRepo>> _fetchGitLabRepos() async {
    final all = <GitProviderRepo>[];
    var url =
        '$_apiBase/projects?membership=true&simple=true&per_page=$_reposPerPage&pagination=keyset&order_by=id&sort=asc';

    while (url.isNotEmpty) {
      final res = await _client.get(Uri.parse(url), headers: _headers);
      if (res.statusCode != 200) {
        throw Exception('API error: ${res.statusCode}');
      }
      final data = jsonDecode(res.body) as List;
      if (data.isEmpty) break;

      for (final project in data) {
        final m = project as Map<String, dynamic>;
        all.add(GitProviderRepo(
          fullName: (m['path_with_namespace'] as String?) ?? '',
          htmlUrl: (m['web_url'] as String?) ?? '',
          isPrivate: m['visibility'] == 'private',
          description: m['description'] as String?,
          language: null,
          updatedAt: m['last_activity_at'] != null
              ? DateTime.tryParse(m['last_activity_at'] as String)
              : null,
        ));
      }

      url = _parseNextLink(res.headers['link']) ?? '';
    }
    return all;
  }

  String? _parseNextLink(String? linkHeader) {
    if (linkHeader == null || linkHeader.isEmpty) return null;
    for (final part in linkHeader.split(',')) {
      final trimmed = part.trim();
      if (trimmed.endsWith('rel="next"')) {
        final match = RegExp(r'<([^>]+)>').firstMatch(trimmed);
        return match?.group(1);
      }
    }
    return null;
  }
}

/// Backward-compatible alias.
typedef GitHubRepo = GitProviderRepo;

typedef GitHubReposService = GitProviderReposService;
