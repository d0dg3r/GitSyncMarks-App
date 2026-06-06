import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/git_provider_caps.dart' as caps;
import '../git_provider.dart';
import '../git_provider_exception.dart';

class GiteaProvider implements GitProviderClient {
  GiteaProvider({
    required this.providerId,
    required this.token,
    required this.owner,
    required this.repo,
    required this.branch,
    String serverUrl = '',
    String basePath = 'bookmarks',
    http.Client? client,
  })  : serverUrl = serverUrl.isNotEmpty
            ? serverUrl
            : caps.getProviderCaps(providerId).defaultServerUrl,
        basePath = basePath,
        _client = client ?? http.Client(),
        _apiBase = caps.resolveApiBase(
          providerId,
          serverUrl.isNotEmpty
              ? serverUrl
              : caps.getProviderCaps(providerId).defaultServerUrl,
        );

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

  Map<String, String> _headers({bool includeAuth = true}) {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    // Gitea rejects invalid tokens even for public repos; omit auth when empty.
    if (includeAuth && token.isNotEmpty) {
      headers['Authorization'] = 'token $token';
    }
    return headers;
  }

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
    bool includeAuth = true,
  }) async {
    final uri = Uri.parse(url);
    final encodedBody = body != null ? json.encode(body) : null;
    final headers = _headers(includeAuth: includeAuth);
    late http.Response response;
    try {
      switch (method) {
        case 'POST':
          response =
              await _client.post(uri, headers: headers, body: encodedBody);
        case 'PUT':
          response =
              await _client.put(uri, headers: headers, body: encodedBody);
        case 'DELETE':
          response = await _client.delete(uri,
              headers: headers, body: encodedBody);
        default:
          response = await _client.get(uri, headers: headers);
      }
    } catch (e) {
      throw GitProviderException('Network error: $e', statusCode: 0);
    }

    if (response.statusCode == 401) {
      throw GitProviderException(
        _apiErrorMessage(response.body) ?? 'Invalid token',
        statusCode: 401,
      );
    }
    if (response.statusCode == 403) {
      throw GitProviderException(
        _apiErrorMessage(response.body) ?? 'Access denied',
        statusCode: 403,
      );
    }
    return response;
  }

  static String? _apiErrorMessage(String body) {
    final parsed = _tryParseJson(body);
    final message = parsed?['message']?.toString().trim();
    return message != null && message.isNotEmpty ? message : null;
  }

  static String _encodeBase64(String str) =>
      base64.encode(utf8.encode(str));

  static String _decodeBase64(String base64Str) {
    final cleaned = base64Str.replaceAll('\n', '');
    return utf8.decode(base64.decode(cleaned));
  }

  static String _pickSha(dynamic meta) {
    if (meta is! Map) return '';
    return (meta['sha'] ?? meta['id'] ?? meta['SHA'] ?? '').toString();
  }

  String _encodeContentPath(String path) {
    if (path.isEmpty) return path;
    return path.split('/').map(Uri.encodeComponent).join('/');
  }

  @override
  Future<String?> getLatestCommitSha() async {
    final refUrl =
        '$_apiBase/repos/$owner/$repo/git/ref/heads/${Uri.encodeComponent(branch)}';
    final refResponse = await _fetch(refUrl);
    if (refResponse.ok) {
      final refData = json.decode(refResponse.body) as Map<String, dynamic>;
      final sha = _pickSha(refData['object']) != ''
          ? _pickSha(refData['object'])
          : _pickSha(refData);
      if (sha.isNotEmpty) return sha;
    }

    final branchUrl =
        '$_apiBase/repos/$owner/$repo/branches/${Uri.encodeComponent(branch)}';
    final branchResponse = await _fetch(branchUrl);
    if (!branchResponse.ok) {
      if (branchResponse.statusCode == 404) return null;
      throw GitProviderException(
        'Branch not found: $branch',
        statusCode: branchResponse.statusCode,
      );
    }
    final branchData =
        json.decode(branchResponse.body) as Map<String, dynamic>;
    final sha = _pickSha(branchData['commit']);
    if (sha.isEmpty) {
      throw GitProviderException('Branch not found: $branch', statusCode: 404);
    }
    return sha;
  }

  @override
  Future<CommitInfo> getCommit(String commitSha) async {
    final sha = commitSha;
    try {
      final treeSha = await getCommitTreeSha(commitSha);
      return CommitInfo(sha: sha, treeSha: treeSha);
    } catch (_) {
      return CommitInfo(sha: sha, treeSha: sha);
    }
  }

  @override
  Future<String> getCommitTreeSha(String commitSha) async {
    if (_lastCommitSha == commitSha && _lastTreeSha != null) {
      return _lastTreeSha!;
    }
    return commitSha;
  }

  @override
  Future<List<TreeEntry>> getTree(String treeSha) async {
    throw GitProviderException(
      'Gitea-family providers use Contents API for tree reads',
      statusCode: 400,
    );
  }

  @override
  Future<String> getBlob(String blobSha) async {
    throw GitProviderException(
      'Gitea-family providers use Contents API for blob reads',
      statusCode: 400,
    );
  }

  @override
  Future<Map<String, String>> fetchBlobsBatched(
    List<MapEntry<String, String>> pathShaPairs, {
    Map<String, SyncFileEntry>? baseFiles,
  }) async {
    final fileMap = <String, String>{};
    for (final entry in pathShaPairs) {
      final base = baseFiles?[entry.key];
      if (base != null && base.sha == entry.value) {
        fileMap[entry.key] = base.content;
      } else {
        fileMap[entry.key] = await getFileContent(entry.key);
      }
    }
    return fileMap;
  }

  @override
  Future<List<CommitEntry>> listCommits({
    String? path,
    int perPage = 20,
  }) async {
    var url =
        '$_apiBase/repos/$owner/$repo/commits?sha=${Uri.encodeComponent(branch)}&limit=$perPage';
    if (path != null) url += '&path=${Uri.encodeComponent(path)}';
    final response = await _fetch(url);
    if (!response.ok) {
      throw GitProviderException(
        'Failed to list commits',
        statusCode: response.statusCode,
      );
    }
    final data = json.decode(response.body) as List<dynamic>;
    return data.map((c) {
      final m = c as Map<String, dynamic>;
      final commit = m['commit'] as Map<String, dynamic>?;
      final author = commit?['author'] as Map<String, dynamic>?;
      return CommitEntry(
        sha: _pickSha(m),
        message: ((commit?['message'] as String?) ?? '').split('\n').first,
        date: author?['date'] as String? ?? '',
        author: author?['name'] as String? ?? '',
      );
    }).toList();
  }

  Future<bool> _isEmptyRepo() async {
    try {
      await getLatestCommitSha();
      return false;
    } on GitProviderException catch (e) {
      if (e.statusCode == 404 || e.statusCode == 409) return true;
      rethrow;
    }
  }

  Future<String?> _resolveContentSha(
    String path,
    Map<String, String> pathToSha,
  ) async {
    try {
      final meta = await getFileMeta(path);
      if (meta?.sha != null && meta!.sha!.isNotEmpty) return meta.sha;
    } catch (_) {}
    return pathToSha[path];
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

    final pathToSha = <String, String>{};
    if (!await _isEmptyRepo()) {
      final latest = await getLatestCommitSha();
      if (latest != null) {
        final map = await fetchFileMapViaContents(basePath, latest);
        pathToSha.addAll(map.shaMap);
      }
    }

    String? lastCommitSha;
    final sorted = entries..sort((a, b) => a.key.compareTo(b.key));

    for (final entry in sorted) {
      if (entry.value == null) {
        final sha = await _resolveContentSha(entry.key, pathToSha);
        if (sha == null || sha.isEmpty) continue;
        final url =
            '$_apiBase/repos/$owner/$repo/contents/${_encodeContentPath(entry.key)}';
        final response = await _fetch(url, method: 'DELETE', body: {
          'message': message,
          'branch': branch,
          'sha': sha,
        });
        if (!response.ok) {
          final err = _tryParseJson(response.body);
          throw GitProviderException(
            err?['message']?.toString() ?? 'Failed to delete ${entry.key}',
            statusCode: response.statusCode,
          );
        }
        final data = json.decode(response.body) as Map<String, dynamic>;
        final deleteSha = _pickSha(data['commit']);
        if (deleteSha.isNotEmpty) {
          lastCommitSha = deleteSha;
          _lastCommitSha = deleteSha;
        }
        pathToSha.remove(entry.key);
        continue;
      }

      final existingSha = await _resolveContentSha(entry.key, pathToSha);
      final result = await createOrUpdateFile(
        entry.key,
        entry.value!,
        message,
        sha: existingSha,
      );
      lastCommitSha = result.commitSha;
      if (result.contentSha != null) {
        pathToSha[entry.key] = result.contentSha!;
      }
    }

    return lastCommitSha ?? (await getLatestCommitSha()) ?? '';
  }

  static Map<String, dynamic>? _tryParseJson(String body) {
    try {
      final r = json.decode(body);
      return r is Map<String, dynamic> ? r : null;
    } catch (_) {
      return null;
    }
  }

  Future<List<dynamic>> _listContentsEntries(String path, String ref) async {
    final suffix =
        path.isNotEmpty ? '/${_encodeContentPath(path)}' : '';
    final url =
        '$_apiBase/repos/$owner/$repo/contents$suffix?ref=${Uri.encodeComponent(ref)}';
    final response = await _fetch(url);
    if (response.statusCode == 404) return [];
    if (!response.ok) {
      throw GitProviderException(
        'Failed to list contents',
        statusCode: response.statusCode,
      );
    }
    final data = json.decode(response.body);
    if (data is List) return data;
    if (data is Map) return [data];
    return [];
  }

  Future<void> _walkContentsForFileMap(
    String dirPath,
    String ref,
    Map<String, String> shaMap,
    Map<String, String> fileMap,
  ) async {
    final entries = await _listContentsEntries(dirPath, ref);
    for (final entry in entries) {
      final m = entry as Map<String, dynamic>;
      final path = (m['path'] ?? '').toString();
      if (path.isEmpty) continue;
      final type = (m['type'] ?? '').toString();
      if (type == 'file') {
        var content = '';
        var sha = _pickSha(m);
        if (m['content'] is String && (m['content'] as String).isNotEmpty) {
          content = _decodeBase64(m['content'] as String);
        } else {
          final file = await _getFileAtRef(path, ref);
          if (file == null) continue;
          content = file.content;
          sha = file.sha.isNotEmpty ? file.sha : sha;
        }
        if (sha.isNotEmpty) shaMap[path] = sha;
        fileMap[path] = content;
      } else if (type == 'dir') {
        await _walkContentsForFileMap(path, ref, shaMap, fileMap);
      }
    }
  }

  Future<({String content, String sha})?> _getFileAtRef(
    String path,
    String ref,
  ) async {
    final url =
        '$_apiBase/repos/$owner/$repo/contents/${_encodeContentPath(path)}?ref=${Uri.encodeComponent(ref)}';
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
      content: _decodeBase64(data['content'] as String? ?? ''),
      sha: _pickSha(data),
    );
  }

  List<String> _resolveContentsRefs(String ref) {
    final primary = ref.trim().isNotEmpty ? ref.trim() : branch;
    final refs = <String>[primary];
    if (branch.isNotEmpty && primary != branch) refs.add(branch);
    final branchRef = 'refs/heads/$branch';
    if (!refs.contains(branchRef)) refs.add(branchRef);
    return refs.toSet().toList();
  }

  /// Fetch bookmark files via Contents API (extension-aligned).
  Future<({Map<String, String> shaMap, Map<String, String> fileMap})>
      fetchFileMapViaContents(String basePath, String ref) async {
    final base = basePath.replaceAll(RegExp(r'/+$'), '');
    final refs = _resolveContentsRefs(ref);
    GitProviderException? lastErr;

    for (final candidate in refs) {
      try {
        final shaMap = <String, String>{};
        final fileMap = <String, String>{};
        await _walkContentsForFileMap(base, candidate, shaMap, fileMap);
        if (fileMap.isNotEmpty || shaMap.isNotEmpty) {
          return (shaMap: shaMap, fileMap: fileMap);
        }
      } on GitProviderException catch (e) {
        lastErr = e;
      }
    }

    if (lastErr != null) throw lastErr;
    return (shaMap: <String, String>{}, fileMap: <String, String>{});
  }

  @override
  Future<List<ContentEntry>> listContents(String path) async {
    final entries = await _listContentsEntries(path, branch);
    return entries.map((e) {
      final m = e as Map<String, dynamic>;
      return ContentEntry(
        name: m['name'] as String,
        type: m['type'] == 'dir' ? 'dir' : 'file',
        path: m['path'] as String?,
        sha: _pickSha(m),
      );
    }).toList();
  }

  @override
  Future<String> getFileContent(String path) async {
    final file = await _getFileAtRef(path, branch);
    if (file == null) {
      throw GitProviderException('File not found: $path', statusCode: 404);
    }
    return file.content;
  }

  @override
  Future<CreateOrUpdateResult> createOrUpdateFile(
    String path,
    String content,
    String message, {
    String? sha,
  }) async {
    final url =
        '$_apiBase/repos/$owner/$repo/contents/${_encodeContentPath(path)}';
    final body = <String, dynamic>{
      'message': message,
      'content': _encodeBase64(content),
      'branch': branch,
    };
    if (sha != null && sha.isNotEmpty) body['sha'] = sha;
    final method = sha != null && sha.isNotEmpty ? 'PUT' : 'POST';
    final response = await _fetch(url, method: method, body: body);
    if (!response.ok) {
      final err = _tryParseJson(response.body);
      throw GitProviderException(
        err?['message']?.toString() ?? 'Failed to write file',
        statusCode: response.statusCode,
      );
    }
    final data = json.decode(response.body) as Map<String, dynamic>;
    final commitSha =
        _pickSha(data['commit']) != '' ? _pickSha(data['commit']) : '';
    final contentSha = data['content'] is Map
        ? _pickSha(data['content'])
        : _pickSha(data);
    if (commitSha.isEmpty) {
      throw GitProviderException(
        'Missing commit SHA in response',
        statusCode: 422,
      );
    }
    _lastCommitSha = commitSha;
    _lastTreeSha = commitSha;
    return CreateOrUpdateResult(
      contentSha: contentSha.isNotEmpty ? contentSha : sha,
      commitSha: commitSha,
    );
  }

  @override
  Future<void> deleteFile(String path, String sha, String message) async {
    final url =
        '$_apiBase/repos/$owner/$repo/contents/${_encodeContentPath(path)}';
    final response = await _fetch(url, method: 'DELETE', body: {
      'message': message,
      'branch': branch,
      'sha': sha,
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
    final file = await _getFileAtRef(path, branch);
    if (file == null) return null;
    return FileMeta(sha: file.sha);
  }

  @override
  Future<String?> getBranchHeadSha() => getLatestCommitSha();

  @override
  Future<bool> checkRepo() async {
    try {
      final response = await _fetch('$_apiBase/repos/$owner/$repo');
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<TokenValidationResult> validateToken() async {
    try {
      final response = await _fetchForTokenValidation('$_apiBase/user');
      if (!response.ok) {
        if (response.statusCode == 401) {
          return TokenValidationResult(valid: false);
        }
        // Scoped tokens (e.g. read:repository only on Codeberg) return 403 on /user.
        if (response.statusCode == 403) {
          return const TokenValidationResult(valid: true, ambiguous: true);
        }
        return TokenValidationResult(
          valid: false,
          ambiguous: response.statusCode >= 500,
        );
      }
      final data = json.decode(response.body) as Map<String, dynamic>;
      return TokenValidationResult(
        valid: true,
        username: data['login'] as String? ?? data['username'] as String?,
        ambiguous: true,
      );
    } catch (_) {
      return TokenValidationResult(valid: false);
    }
  }

  /// Like [_fetch] but does not throw on 401/403 (token probe only).
  Future<http.Response> _fetchForTokenValidation(String url) async {
    final uri = Uri.parse(url);
    try {
      return await _client.get(uri, headers: _headers());
    } catch (e) {
      throw GitProviderException('Network error: $e', statusCode: 0);
    }
  }

  @override
  void close() => _client.close();
}

extension on http.Response {
  bool get ok => statusCode >= 200 && statusCode < 300;
}
