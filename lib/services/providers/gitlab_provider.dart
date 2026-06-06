import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/git_provider_caps.dart' as caps;
import '../git_provider.dart';
import '../git_provider_exception.dart';

class GitLabProvider implements GitProviderClient {
  GitLabProvider({
    String providerId = caps.GitProviders.gitlab,
    required this.token,
    required this.owner,
    required this.repo,
    required this.branch,
    this.serverUrl = '',
    String basePath = 'bookmarks',
    http.Client? client,
  })  : providerId = providerId,
        basePath = basePath,
        _client = client ?? http.Client(),
        _apiBase = caps.resolveApiBase(providerId, serverUrl);

  @override
  final String providerId;
  final String token;
  @override
  final String owner;
  @override
  final String repo;
  @override
  final String branch;
  final String serverUrl;
  @override
  final String basePath;
  final String _apiBase;
  final http.Client _client;

  String? _lastCommitSha;
  String? _lastTreeSha;

  String get _projectPath => Uri.encodeComponent('$owner/$repo');

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

  @override
  String webBaseUrl() => caps.resolveWebBaseUrl(providerId, serverUrl);

  @override
  String buildCommitUrl(String commitSha) => caps.buildCommitUrl(
        providerId: providerId,
        serverUrl: serverUrl,
        owner: owner,
        repo: repo,
        commitSha: commitSha,
      );

  Future<http.Response> _fetch(
    String url, {
    String method = 'GET',
    Object? body,
  }) async {
    final uri = Uri.parse(url);
    final encodedBody = body != null ? json.encode(body) : null;
    late http.Response response;
    try {
      switch (method) {
        case 'POST':
          response =
              await _client.post(uri, headers: _headers, body: encodedBody);
        case 'PUT':
          response =
              await _client.put(uri, headers: _headers, body: encodedBody);
        case 'DELETE':
          response = await _client.delete(uri,
              headers: _headers, body: encodedBody);
        default:
          response = await _client.get(uri, headers: _headers);
      }
    } catch (e) {
      throw GitProviderException('Network error: $e', statusCode: 0);
    }

    if (response.statusCode == 401) {
      throw GitProviderException('Invalid token', statusCode: 401);
    }
    if (response.statusCode == 403) {
      throw GitProviderException('Access denied', statusCode: 403);
    }
    return response;
  }

  static String _encodeBase64(String str) =>
      base64.encode(utf8.encode(str));

  static String _decodeBase64(String base64Str) {
    final cleaned = base64Str.replaceAll('\n', '');
    return utf8.decode(base64.decode(cleaned));
  }

  static String? _parseNextLink(String? linkHeader) {
    if (linkHeader == null) return null;
    for (final part in linkHeader.split(',')) {
      final match = RegExp(r'<([^>]+)>;\s*rel="next"', caseSensitive: false)
          .firstMatch(part);
      if (match != null) return match.group(1);
    }
    return null;
  }

  String _encodeFilePath(String path) => Uri.encodeComponent(path);

  @override
  Future<String?> getLatestCommitSha() async {
    final url =
        '$_apiBase/projects/$_projectPath/repository/branches/${Uri.encodeComponent(branch)}';
    final response = await _fetch(url);
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) {
      throw GitProviderException(
        'Branch not found: $branch',
        statusCode: response.statusCode,
      );
    }
    final data = json.decode(response.body) as Map<String, dynamic>;
    final sha = (data['commit'] as Map<String, dynamic>?)?['id'] as String?;
    if (sha == null || sha.isEmpty) {
      throw GitProviderException('Branch not found: $branch', statusCode: 404);
    }
    return sha;
  }

  @override
  Future<CommitInfo> getCommit(String commitSha) async {
    final url =
        '$_apiBase/projects/$_projectPath/repository/commits/$commitSha';
    final response = await _fetch(url);
    if (response.statusCode != 200) {
      throw GitProviderException(
        'Failed to get commit $commitSha',
        statusCode: response.statusCode,
      );
    }
    final data = json.decode(response.body) as Map<String, dynamic>;
    final sha = data['id'] as String? ?? commitSha;
    return CommitInfo(sha: sha, treeSha: sha);
  }

  @override
  Future<String> getCommitTreeSha(String commitSha) async {
    if (_lastCommitSha == commitSha && _lastTreeSha != null) {
      return _lastTreeSha!;
    }
    return commitSha;
  }

  Future<({List<TreeEntry> tree, bool truncated})?> _getRecursiveTree(
    String ref,
  ) async {
    final tree = <TreeEntry>[];
    var url =
        '$_apiBase/projects/$_projectPath/repository/tree?ref=${Uri.encodeComponent(ref)}&recursive=true&per_page=100&pagination=keyset';
    while (url.isNotEmpty) {
      final response = await _fetch(url);
      if (!response.ok) return null;
      final data = json.decode(response.body) as List<dynamic>;
      for (final entry in data) {
        final m = entry as Map<String, dynamic>;
        final path = m['path'] as String?;
        if (path == null) continue;
        tree.add(TreeEntry(
          path: path,
          mode: '100644',
          type: m['type'] == 'tree' ? 'tree' : 'blob',
          sha: (m['id'] ?? '').toString(),
        ));
      }
      final next = _parseNextLink(response.headers['link']);
      url = next ?? '';
    }
    return (tree: tree, truncated: false);
  }

  @override
  Future<List<TreeEntry>> getTree(String treeSha) async {
    final result = await _getRecursiveTree(treeSha);
    if (result == null) {
      throw GitProviderException('Failed to get tree $treeSha', statusCode: 404);
    }
    return result.tree;
  }

  @override
  Future<String> getBlob(String blobSha) async {
    final url =
        '$_apiBase/projects/$_projectPath/repository/blobs/$blobSha/raw';
    final response = await _fetch(url);
    if (response.statusCode != 200) {
      throw GitProviderException(
        'Failed to get blob $blobSha',
        statusCode: response.statusCode,
      );
    }
    return response.body;
  }

  @override
  Future<Map<String, String>> fetchBlobsBatched(
    List<MapEntry<String, String>> pathShaPairs, {
    Map<String, SyncFileEntry>? baseFiles,
  }) async {
    final fileMap = <String, String>{};
    final toFetch = <MapEntry<String, String>>[];

    for (final entry in pathShaPairs) {
      final base = baseFiles?[entry.key];
      if (base != null && base.sha == entry.value) {
        fileMap[entry.key] = base.content;
      } else {
        toFetch.add(entry);
      }
    }

    for (final entry in toFetch) {
      fileMap[entry.key] = await getBlob(entry.value);
    }
    return fileMap;
  }

  @override
  Future<List<CommitEntry>> listCommits({
    String? path,
    int perPage = 20,
  }) async {
    final params = <String, String>{
      'ref_name': branch,
      'per_page': perPage.toString(),
    };
    if (path != null) params['path'] = path;
    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    final url =
        '$_apiBase/projects/$_projectPath/repository/commits?$query';
    final response = await _fetch(url);
    if (response.statusCode != 200) {
      throw GitProviderException(
        'Failed to list commits',
        statusCode: response.statusCode,
      );
    }
    final data = json.decode(response.body) as List<dynamic>;
    return data.map((c) {
      final m = c as Map<String, dynamic>;
      return CommitEntry(
        sha: m['id'] as String? ?? '',
        message: ((m['title'] as String?) ?? (m['message'] as String?) ?? '')
            .split('\n')
            .first,
        date: (m['committed_date'] as String?) ??
            (m['created_at'] as String?) ??
            '',
        author: (m['author_name'] as String?) ??
            ((m['author'] as Map<String, dynamic>?)?['name'] as String?) ??
            '',
      );
    }).toList();
  }

  @override
  Future<String> atomicCommit(
    String message,
    Map<String, String?> fileChanges,
  ) async {
    final entries = fileChanges.entries.toList();
    if (entries.isEmpty) {
      return (await getLatestCommitSha()) ?? '';
    }

    final existingPaths = <String>{};
    try {
      final latestSha = await getLatestCommitSha();
      if (latestSha != null) {
        final tree = await _getRecursiveTree(latestSha);
        if (tree != null) {
          for (final e in tree.tree) {
            if (e.type == 'blob') existingPaths.add(e.path);
          }
        }
      }
    } on GitProviderException catch (e) {
      if (e.statusCode != 404 && e.statusCode != 409) rethrow;
    }

    final actions = <Map<String, dynamic>>[];
    for (final entry in entries..sort((a, b) => a.key.compareTo(b.key))) {
      if (entry.value == null) {
        if (existingPaths.contains(entry.key)) {
          actions.add({'action': 'delete', 'file_path': entry.key});
        }
        continue;
      }
      actions.add({
        'action': existingPaths.contains(entry.key) ? 'update' : 'create',
        'file_path': entry.key,
        'content': _encodeBase64(entry.value!),
        'encoding': 'base64',
      });
    }

    if (actions.isEmpty) {
      return (await getLatestCommitSha()) ?? '';
    }

    final url =
        '$_apiBase/projects/$_projectPath/repository/commits';
    final response = await _fetch(url, method: 'POST', body: {
      'branch': branch,
      'commit_message': message,
      'actions': actions,
    });

    if (response.statusCode != 201) {
      final err = _tryParseJson(response.body);
      throw GitProviderException(
        err?['message']?.toString() ??
            'GitLab commit failed (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final commitSha = data['id'] as String? ?? '';
    if (commitSha.isEmpty) {
      throw GitProviderException(
        'GitLab commit response missing commit id',
        statusCode: 422,
      );
    }
    _lastCommitSha = commitSha;
    _lastTreeSha = commitSha;
    return commitSha;
  }

  static Map<String, dynamic>? _tryParseJson(String body) {
    try {
      final r = json.decode(body);
      return r is Map<String, dynamic> ? r : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ContentEntry>> listContents(String path) async {
    final params = 'ref=${Uri.encodeComponent(branch)}&per_page=100';
    final pathParam = path.isNotEmpty ? '&path=${Uri.encodeComponent(path)}' : '';
    final url =
        '$_apiBase/projects/$_projectPath/repository/tree?$params$pathParam';
    final response = await _fetch(url);
    if (response.statusCode == 404) return [];
    if (!response.ok) {
      throw GitProviderException(
        'Failed to list contents',
        statusCode: response.statusCode,
      );
    }
    final data = json.decode(response.body) as List<dynamic>;
    return data
        .where((e) => (e as Map)['type'] == 'tree')
        .map((e) {
          final m = e as Map<String, dynamic>;
          return ContentEntry(
            name: m['name'] as String,
            type: 'dir',
            path: m['path'] as String?,
          );
        })
        .toList();
  }

  @override
  Future<String> getFileContent(String path) async {
    final file = await _getFile(path);
    if (file == null) {
      throw GitProviderException('File not found: $path', statusCode: 404);
    }
    return file.content;
  }

  Future<({String content, String sha})?> _getFile(String path) async {
    final url =
        '$_apiBase/projects/$_projectPath/repository/files/${_encodeFilePath(path)}?ref=${Uri.encodeComponent(branch)}';
    final response = await _fetch(url);
    if (response.statusCode == 404) return null;
    if (!response.ok) {
      throw GitProviderException(
        'Failed to read file',
        statusCode: response.statusCode,
      );
    }
    final data = json.decode(response.body) as Map<String, dynamic>;
    return (
      content: _decodeBase64(data['content'] as String),
      sha: (data['last_commit_id'] ?? data['blob_id'] ?? '').toString(),
    );
  }

  @override
  Future<CreateOrUpdateResult> createOrUpdateFile(
    String path,
    String content,
    String message, {
    String? sha,
  }) async {
    final encodedPath = _encodeFilePath(path);
    final url =
        '$_apiBase/projects/$_projectPath/repository/files/$encodedPath';
    final body = <String, dynamic>{
      'branch': branch,
      'content': _encodeBase64(content),
      'encoding': 'base64',
      'commit_message': message,
    };
    if (sha != null) body['last_commit_id'] = sha;
    final method = sha != null ? 'PUT' : 'POST';
    final response = await _fetch(url, method: method, body: body);
    if (!response.ok) {
      final err = _tryParseJson(response.body);
      throw GitProviderException(
        err?['message']?.toString() ?? 'Failed to write file',
        statusCode: response.statusCode,
      );
    }
    final data = json.decode(response.body) as Map<String, dynamic>;
    final commitSha = data['id'] as String? ?? data['commit_id'] as String?;
    return CreateOrUpdateResult(
      contentSha: data['blob_id'] as String? ?? sha,
      commitSha: commitSha,
    );
  }

  @override
  Future<void> deleteFile(String path, String sha, String message) async {
    final encodedPath = _encodeFilePath(path);
    final url =
        '$_apiBase/projects/$_projectPath/repository/files/$encodedPath';
    final response = await _fetch(url, method: 'DELETE', body: {
      'branch': branch,
      'commit_message': message,
      'last_commit_id': sha,
    });
    if (!response.ok) {
      throw GitProviderException(
        'Failed to delete file',
        statusCode: response.statusCode,
      );
    }
  }

  @override
  Future<FileMeta?> getFileMeta(String path) async {
    final file = await _getFile(path);
    if (file == null) return null;
    return FileMeta(sha: file.sha);
  }

  @override
  Future<String?> getBranchHeadSha() => getLatestCommitSha();

  @override
  Future<bool> checkRepo() async {
    try {
      final response =
          await _fetch('$_apiBase/projects/$_projectPath');
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<TokenValidationResult> validateToken() async {
    try {
      final response = await _fetch('$_apiBase/user');
      if (!response.ok) {
        if (response.statusCode == 401) {
          return TokenValidationResult(valid: false);
        }
        return TokenValidationResult(
          valid: response.statusCode != 403,
          ambiguous: true,
        );
      }
      final data = json.decode(response.body) as Map<String, dynamic>;
      var scopes = <String>[];
      var ambiguous = true;
      try {
        final scopeResponse =
            await _fetch('$_apiBase/personal_access_tokens/self');
        if (scopeResponse.ok) {
          final scopeData =
              json.decode(scopeResponse.body) as Map<String, dynamic>;
          final raw = scopeData['scopes'] ?? scopeData['scope'];
          if (raw is List) {
            scopes = raw.map((e) => e.toString()).toList();
          } else if (raw != null) {
            scopes = raw.toString().split(',').map((s) => s.trim()).toList();
          }
          ambiguous = false;
        }
      } catch (_) {}
      return TokenValidationResult(
        valid: true,
        username: data['username'] as String? ?? data['name'] as String?,
        scopes: scopes,
        ambiguous: ambiguous,
      );
    } catch (_) {
      return TokenValidationResult(valid: false);
    }
  }

  @override
  void close() => _client.close();
}

extension on http.Response {
  bool get ok => statusCode >= 200 && statusCode < 300;
}
