import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/git_provider_caps.dart' as caps;
import '../git_provider.dart';
import '../git_provider_exception.dart';

const int _treeBatchMaxEntries = 400;
const int _treeBatchMaxBytes = 28 * 1024 * 1024;
const int _blobConcurrency = 5;

List<List<Map<String, dynamic>>> _chunkTreeBatches(
  List<String> deletions,
  List<_UploadEntry> uploads,
) {
  final batches = <List<Map<String, dynamic>>>[];
  var batch = <Map<String, dynamic>>[];
  var approxBytes = 0;

  void flush() {
    if (batch.isNotEmpty) {
      batches.add(batch);
      batch = <Map<String, dynamic>>[];
      approxBytes = 0;
    }
  }

  int approxItemBytes(Map<String, dynamic> item) {
    var n = 64 + ((item['path'] as String).length * 2);
    if (item.containsKey('content')) {
      n += utf8.encode(item['content'] as String).length;
    }
    return n;
  }

  void push(Map<String, dynamic> item) {
    final ib = approxItemBytes(item);
    if (batch.isNotEmpty &&
        (batch.length >= _treeBatchMaxEntries ||
            approxBytes + ib > _treeBatchMaxBytes)) {
      flush();
    }
    batch.add(item);
    approxBytes += ib;
  }

  for (final path in deletions) {
    push({'path': path, 'mode': '100644', 'type': 'blob', 'sha': null});
  }
  for (final u in uploads) {
    push({'path': u.path, 'mode': '100644', 'type': 'blob', 'content': u.content});
  }
  flush();
  return batches;
}

class _UploadEntry {
  _UploadEntry(this.path, this.content);
  final String path;
  final String content;
}

/// GitHub / GitHub Enterprise Git Data + Contents API adapter.
class GithubProvider implements GitProviderClient {
  GithubProvider({
    String providerId = caps.GitProviders.github,
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

  bool get _isGitHubCom => _apiBase.contains('api.github.com');

  Map<String, String> get _headers => {
        'Accept': _isGitHubCom
            ? 'application/vnd.github.v3+json'
            : 'application/vnd.github+json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        if (_isGitHubCom) 'X-GitHub-Api-Version': '2022-11-28',
      };

  Map<String, String> get _contentsHeaders => {
        'Accept': 'application/vnd.github+json',
        'Authorization': 'token $token',
        'X-GitHub-Api-Version': '2022-11-28',
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

  Future<http.Response> _request(
    String url, {
    String method = 'GET',
    Object? body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(url);
    final encodedBody = body != null ? json.encode(body) : null;
    final h = headers ?? _headers;

    late http.Response response;
    switch (method) {
      case 'POST':
        response = await _client.post(uri, headers: h, body: encodedBody);
      case 'PATCH':
        response = await _client.patch(uri, headers: h, body: encodedBody);
      case 'PUT':
        response = await _client.put(uri, headers: h, body: encodedBody);
      case 'DELETE':
        response = await _client.delete(uri, headers: h, body: encodedBody);
      default:
        response = await _client.get(uri, headers: h);
    }

    if (response.statusCode == 401) {
      throw GitProviderException('Invalid token', statusCode: 401);
    }
    if (response.statusCode == 429) {
      throw GitProviderException('Rate limit exceeded', statusCode: 429);
    }
    if (response.statusCode == 403) {
      final data = _tryParseJson(response.body);
      if (data?['message']?.toString().contains('rate limit') == true) {
        throw GitProviderException('Rate limit exceeded', statusCode: 403);
      }
      throw GitProviderException('Access denied', statusCode: 403);
    }
    return response;
  }

  static Map<String, dynamic>? _tryParseJson(String body) {
    try {
      final result = json.decode(body);
      return result is Map<String, dynamic> ? result : null;
    } catch (_) {
      return null;
    }
  }

  static String _decodeBase64Content(String encoded) {
    return utf8.decode(base64.decode(encoded.replaceAll('\n', '')));
  }

  static String _encodeBase64(String content) {
    return base64.encode(utf8.encode(content));
  }

  static String? _parseErrorMessage(String? body) {
    if (body == null || body.isEmpty) return null;
    final decoded = _tryParseJson(body);
    final msg = decoded?['message'] as String?;
    return msg?.trim().isNotEmpty == true ? msg : null;
  }

  String _encodePath(String path) {
    if (path.isEmpty) return path;
    return path.split('/').map(Uri.encodeComponent).join('/');
  }

  @override
  Future<String?> getLatestCommitSha() async {
    final branchEnc = Uri.encodeComponent(branch);
    final response = await _request(
      '$_apiBase/repos/$owner/$repo/git/ref/heads/$branchEnc',
    );
    if (response.statusCode == 404 || response.statusCode == 409) {
      return null;
    }
    if (response.statusCode != 200) {
      throw GitProviderException(
        'Branch not found: $branch',
        statusCode: response.statusCode,
      );
    }
    final data = json.decode(response.body) as Map<String, dynamic>;
    return (data['object'] as Map<String, dynamic>)['sha'] as String;
  }

  @override
  Future<CommitInfo> getCommit(String commitSha) async {
    final response = await _request(
      '$_apiBase/repos/$owner/$repo/git/commits/$commitSha',
    );
    if (response.statusCode != 200) {
      throw GitProviderException(
        'Failed to get commit $commitSha',
        statusCode: response.statusCode,
      );
    }
    final data = json.decode(response.body) as Map<String, dynamic>;
    final tree = data['tree'] as Map<String, dynamic>;
    return CommitInfo(
      sha: data['sha'] as String,
      treeSha: tree['sha'] as String,
    );
  }

  @override
  Future<String> getCommitTreeSha(String commitSha) async {
    final commit = await getCommit(commitSha);
    return commit.treeSha;
  }

  @override
  Future<List<TreeEntry>> getTree(String treeSha) async {
    final response = await _request(
      '$_apiBase/repos/$owner/$repo/git/trees/$treeSha?recursive=1',
    );
    if (response.statusCode != 200) {
      throw GitProviderException(
        'Failed to get tree $treeSha',
        statusCode: response.statusCode,
      );
    }
    final data = json.decode(response.body) as Map<String, dynamic>;
    if (data['truncated'] == true) {
      throw GitProviderException(
        'Git tree listing truncated — repo too large for safe sync',
        statusCode: 422,
      );
    }
    final entries = data['tree'] as List<dynamic>? ?? [];
    return entries.map((e) {
      final m = e as Map<String, dynamic>;
      return TreeEntry(
        path: m['path'] as String,
        mode: m['mode'] as String,
        type: m['type'] as String,
        sha: m['sha'] as String,
        size: m['size'] as int?,
      );
    }).toList();
  }

  @override
  Future<String> getBlob(String blobSha) async {
    final response = await _request(
      '$_apiBase/repos/$owner/$repo/git/blobs/$blobSha',
    );
    if (response.statusCode != 200) {
      throw GitProviderException(
        'Failed to get blob $blobSha',
        statusCode: response.statusCode,
      );
    }
    final data = json.decode(response.body) as Map<String, dynamic>;
    return _decodeBase64Content(data['content'] as String);
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

    for (var i = 0; i < toFetch.length; i += _blobConcurrency) {
      final batch = toFetch.sublist(
        i,
        i + _blobConcurrency > toFetch.length
            ? toFetch.length
            : i + _blobConcurrency,
      );
      final results = await Future.wait(
        batch.map((e) async {
          final content = await getBlob(e.value);
          return MapEntry(e.key, content);
        }),
      );
      for (final r in results) {
        fileMap[r.key] = r.value;
      }
    }
    return fileMap;
  }

  @override
  Future<List<CommitEntry>> listCommits({
    String? path,
    int perPage = 20,
  }) async {
    final branchEnc = Uri.encodeComponent(branch);
    var url =
        '$_apiBase/repos/$owner/$repo/commits?sha=$branchEnc&per_page=$perPage';
    if (path != null) url += '&path=${Uri.encodeComponent(path)}';

    final response = await _request(url);
    if (response.statusCode != 200) {
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
      final committer = commit?['committer'] as Map<String, dynamic>?;
      return CommitEntry(
        sha: m['sha'] as String,
        message: ((commit?['message'] as String?) ?? '').split('\n').first,
        date: (committer?['date'] as String?) ??
            (author?['date'] as String?) ??
            '',
        author: (author?['name'] as String?) ??
            ((m['author'] as Map<String, dynamic>?)?['login'] as String?) ??
            '',
      );
    }).toList();
  }

  Future<String> _createTree(
    String? baseTreeSha,
    List<Map<String, dynamic>> items,
  ) async {
    final body = <String, dynamic>{'tree': items};
    if (baseTreeSha != null) body['base_tree'] = baseTreeSha;

    final response = await _request(
      '$_apiBase/repos/$owner/$repo/git/trees',
      method: 'POST',
      body: body,
    );
    if (response.statusCode != 201) {
      final err = _tryParseJson(response.body);
      throw GitProviderException(
        'Failed to create tree: ${err?['message'] ?? response.statusCode}',
        statusCode: response.statusCode,
      );
    }
    final data = json.decode(response.body) as Map<String, dynamic>;
    return data['sha'] as String;
  }

  Future<String> _createCommit(
    String message,
    String treeSha, {
    String? parentSha,
  }) async {
    final body = <String, dynamic>{
      'message': message,
      'tree': treeSha,
      'parents': parentSha != null ? [parentSha] : <String>[],
    };
    final response = await _request(
      '$_apiBase/repos/$owner/$repo/git/commits',
      method: 'POST',
      body: body,
    );
    if (response.statusCode != 201) {
      throw GitProviderException(
        'Failed to create commit',
        statusCode: response.statusCode,
      );
    }
    final data = json.decode(response.body) as Map<String, dynamic>;
    return data['sha'] as String;
  }

  Future<void> _updateRef(String commitSha) async {
    final branchEnc = Uri.encodeComponent(branch);
    final response = await _request(
      '$_apiBase/repos/$owner/$repo/git/refs/heads/$branchEnc',
      method: 'PATCH',
      body: {'sha': commitSha},
    );
    if (response.statusCode != 200) {
      final err = _tryParseJson(response.body);
      throw GitProviderException(
        'Failed to update ref: ${err?['message'] ?? response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  Future<void> _createRef(String commitSha) async {
    final response = await _request(
      '$_apiBase/repos/$owner/$repo/git/refs',
      method: 'POST',
      body: {'ref': 'refs/heads/$branch', 'sha': commitSha},
    );
    if (response.statusCode != 201) {
      throw GitProviderException(
        'Failed to create ref',
        statusCode: response.statusCode,
      );
    }
  }

  Future<String> _buildLayeredTree(
    String? baseTreeSha,
    List<List<Map<String, dynamic>>> batches,
  ) async {
    var sha = baseTreeSha;
    for (final batch in batches) {
      sha = await _createTree(sha, batch);
    }
    return sha!;
  }

  @override
  Future<String> atomicCommit(
    String message,
    Map<String, String?> fileChanges,
  ) async {
    String? currentCommitSha;
    String? currentTreeSha;
    var isEmptyRepo = false;

    try {
      currentCommitSha = await getLatestCommitSha();
      if (currentCommitSha == null) {
        isEmptyRepo = true;
      } else {
        final commit = await getCommit(currentCommitSha);
        currentTreeSha = commit.treeSha;
      }
    } on GitProviderException catch (e) {
      if (e.statusCode == 404 || e.statusCode == 409) {
        isEmptyRepo = true;
      } else {
        rethrow;
      }
    }

    final deletions = <String>[];
    final uploads = <_UploadEntry>[];
    for (final entry in fileChanges.entries) {
      if (entry.value == null) {
        if (!isEmptyRepo) deletions.add(entry.key);
      } else {
        uploads.add(_UploadEntry(entry.key, entry.value!));
      }
    }

    if (deletions.isEmpty && uploads.isEmpty) return currentCommitSha ?? '';

    final batches = _chunkTreeBatches(deletions, uploads);

    if (isEmptyRepo) {
      return _commitOnEmptyRepo(message, batches);
    }
    return _commitOnExistingBranch(
      message,
      batches,
      currentTreeSha!,
      currentCommitSha!,
    );
  }

  Future<String> _commitOnExistingBranch(
    String message,
    List<List<Map<String, dynamic>>> batches,
    String baseTreeSha,
    String parentSha,
  ) async {
    var tree = baseTreeSha;
    var parent = parentSha;

    for (var attempt = 0; attempt < 3; attempt++) {
      final newTreeSha = await _buildLayeredTree(tree, batches);
      final newCommitSha =
          await _createCommit(message, newTreeSha, parentSha: parent);
      try {
        await _updateRef(newCommitSha);
        return newCommitSha;
      } on GitProviderException catch (e) {
        final isConflict = e.statusCode == 409 || e.statusCode == 422;
        if (!isConflict || attempt >= 2) rethrow;

        final freshSha = await getLatestCommitSha();
        if (freshSha == null) rethrow;
        final freshCommit = await getCommit(freshSha);
        tree = freshCommit.treeSha;
        parent = freshCommit.sha;
      }
    }
    throw GitProviderException(
      'Failed to update ref after retries',
      statusCode: 409,
    );
  }

  Future<String> _commitOnEmptyRepo(
    String message,
    List<List<Map<String, dynamic>>> batches,
  ) async {
    for (var attempt = 0; attempt < 4; attempt++) {
      final newTreeSha = await _buildLayeredTree(null, batches);
      final newCommitSha = await _createCommit(message, newTreeSha);
      try {
        await _createRef(newCommitSha);
        return newCommitSha;
      } on GitProviderException catch (e) {
        final isConflict = e.statusCode == 409 || e.statusCode == 422;
        if (!isConflict) rethrow;

        try {
          final latestSha = await getLatestCommitSha();
          if (latestSha != null) {
            final fresh = await getCommit(latestSha);
            return _commitOnExistingBranch(
              message,
              batches,
              fresh.treeSha,
              fresh.sha,
            );
          }
        } on GitProviderException {
          if (attempt >= 3) rethrow;
        }
      }
    }
    throw GitProviderException(
      'Failed to create initial branch ref after retries',
      statusCode: 409,
    );
  }

  @override
  Future<List<ContentEntry>> listContents(String path) async {
    final pathEncoded = _encodePath(path);
    final uri =
        '$_apiBase/repos/$owner/$repo/contents/$pathEncoded?ref=${Uri.encodeQueryComponent(branch)}';
    final response = await _request(uri, headers: _contentsHeaders);
    if (response.statusCode != 200) {
      throw GitProviderException(
        _parseErrorMessage(response.body) ??
            'Failed to fetch contents: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
    final decoded = json.decode(response.body);
    if (decoded is! List) {
      throw GitProviderException('Expected list response for directory');
    }
    return decoded
        .map<ContentEntry>((e) => ContentEntry(
              name: e['name'] as String,
              type: e['type'] as String,
              path: e['path'] as String?,
              content: e['content'] as String?,
              encoding: e['encoding'] as String?,
              sha: e['sha'] as String?,
            ))
        .toList();
  }

  @override
  Future<String> getFileContent(String path) async {
    final pathEncoded = _encodePath(path);
    final uri =
        '$_apiBase/repos/$owner/$repo/contents/$pathEncoded?ref=${Uri.encodeQueryComponent(branch)}';
    final response = await _request(uri, headers: _contentsHeaders);
    if (response.statusCode != 200) {
      throw GitProviderException(
        _parseErrorMessage(response.body) ??
            'Failed to fetch file: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
    final decoded = json.decode(response.body) as Map<String, dynamic>;
    final content = decoded['content'] as String?;
    final encoding = decoded['encoding'] as String?;
    if (content == null) {
      throw GitProviderException('File has no content');
    }
    return encoding == 'base64' ? _decodeBase64Content(content) : content;
  }

  @override
  Future<CreateOrUpdateResult> createOrUpdateFile(
    String path,
    String content,
    String message, {
    String? sha,
  }) async {
    final pathEncoded = _encodePath(path);
    final uri = '$_apiBase/repos/$owner/$repo/contents/$pathEncoded';
    final body = <String, dynamic>{
      'message': message,
      'content': _encodeBase64(content),
      'branch': branch,
    };
    if (sha != null && sha.isNotEmpty) body['sha'] = sha;

    final response = await _request(
      uri,
      method: 'PUT',
      body: body,
      headers: _contentsHeaders,
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw GitProviderException(
        _parseErrorMessage(response.body) ??
            'Failed to write file: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
    final decoded = json.decode(response.body) as Map<String, dynamic>;
    final contentData = decoded['content'];
    final commitData = decoded['commit'];
    return CreateOrUpdateResult(
      contentSha: contentData is Map ? contentData['sha'] as String? : null,
      commitSha: commitData is Map ? commitData['sha'] as String? : null,
    );
  }

  @override
  Future<void> deleteFile(String path, String sha, String message) async {
    final pathEncoded = _encodePath(path);
    final uri = '$_apiBase/repos/$owner/$repo/contents/$pathEncoded';
    final response = await _request(
      uri,
      method: 'DELETE',
      body: {'message': message, 'sha': sha, 'branch': branch},
      headers: _contentsHeaders,
    );
    if (response.statusCode != 200) {
      throw GitProviderException(
        _parseErrorMessage(response.body) ??
            'Failed to delete file: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  @override
  Future<FileMeta?> getFileMeta(String path) async {
    final pathEncoded = _encodePath(path);
    final uri =
        '$_apiBase/repos/$owner/$repo/contents/$pathEncoded?ref=${Uri.encodeQueryComponent(branch)}';
    final response = await _request(uri, headers: _contentsHeaders);
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) {
      throw GitProviderException(
        _parseErrorMessage(response.body) ??
            'Failed to fetch file: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
    final decoded = json.decode(response.body) as Map<String, dynamic>;
    return FileMeta(sha: decoded['sha'] as String?);
  }

  @override
  Future<String?> getBranchHeadSha() async {
    final branchEncoded = Uri.encodeComponent(branch);
    final uri = '$_apiBase/repos/$owner/$repo/branches/$branchEncoded';
    final response = await _request(uri, headers: _contentsHeaders);
    if (response.statusCode != 200) return null;
    final decoded = json.decode(response.body) as Map<String, dynamic>;
    final commit = decoded['commit'];
    if (commit is! Map<String, dynamic>) return null;
    final sha = commit['sha'] as String?;
    return sha?.trim().isNotEmpty == true ? sha : null;
  }

  @override
  Future<bool> checkRepo() async {
    try {
      final response = await _request('$_apiBase/repos/$owner/$repo');
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<TokenValidationResult> validateToken() async {
    try {
      final response = await _request('$_apiBase/user');
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
      final scopesHeader = response.headers['x-oauth-scopes'] ?? '';
      final scopes = scopesHeader
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      return TokenValidationResult(
        valid: true,
        username: data['login'] as String?,
        scopes: scopes,
        ambiguous: scopes.isEmpty,
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

/// Backward-compatible alias.
typedef GitDataApi = GithubProvider;
