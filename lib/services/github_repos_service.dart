import 'dart:convert';

import 'package:http/http.dart' as http;

const _apiBase = 'https://api.github.com';
const _reposPerPage = 100;

class GitHubRepo {
  const GitHubRepo({
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

class GitHubReposService {
  GitHubReposService({required this.token});

  final String token;

  Map<String, String> get _headers => {
        'Authorization': 'token $token',
        'Accept': 'application/vnd.github.v3+json',
      };

  Future<String> fetchCurrentUser() async {
    final res = await http.get(
      Uri.parse('$_apiBase/user'),
      headers: _headers,
    );
    if (res.statusCode != 200) {
      throw Exception('GitHub API error: ${res.statusCode}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return (data['login'] as String?) ?? '';
  }

  Future<List<GitHubRepo>> fetchUserRepos() async {
    final all = <GitHubRepo>[];
    var page = 1;

    while (true) {
      final res = await http.get(
        Uri.parse(
          '$_apiBase/user/repos?per_page=$_reposPerPage&type=all&sort=updated&page=$page',
        ),
        headers: _headers,
      );
      if (res.statusCode != 200) {
        throw Exception('GitHub API error: ${res.statusCode}');
      }
      final data = jsonDecode(res.body) as List;
      if (data.isEmpty) break;

      for (final r in data) {
        final m = r as Map<String, dynamic>;
        all.add(GitHubRepo(
          fullName: (m['full_name'] as String?) ?? '',
          htmlUrl: (m['html_url'] as String?) ??
              'https://github.com/${m['full_name']}',
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
}
