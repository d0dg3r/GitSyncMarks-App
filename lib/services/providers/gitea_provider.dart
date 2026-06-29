import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/git_provider_caps.dart' as caps;
import '../git_provider.dart';
import '../git_provider_exception.dart';
import '../git_tree_batch.dart';

const int _blobConcurrency = 5;
const Set<int> _giteaWriteFallbackStatuses = {401, 404, 405, 422, 501};

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
        case 'PATCH':
          response =
              await _client.patch(uri, headers: headers, body: encodedBody);
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

  static String _pickTreeShaFromCommitPayload(Map<String, dynamic>? data) {
    if (data == null) return '';
    final direct = _pickSha(data['tree']) != ''
        ? _pickSha(data['tree'])
        : _pickSha((data['commit'] as Map?)?['tree']) != ''
            ? _pickSha((data['commit'] as Map?)?['tree'])
            : (data['tree_sha'] as String?) ?? '';
    if (direct.isNotEmpty) return direct;

    final treeMeta = (data['commit'] as Map?)?['tree'] ?? data['tree'];
    if (treeMeta is Map) {
      final url = treeMeta['url']?.toString() ?? '';
      final match = RegExp(r'/git/trees/([0-9a-f]{7,64})', caseSensitive: false)
          .firstMatch(url);
      if (match != null) return match.group(1)!;
    }
    return '';
  }

  String _encodeContentPath(String path) {
    if (path.isEmpty) return path;
    return path.split('/').map(Uri.encodeComponent).join('/');
  }

  Future<Map<String, dynamic>?> _fetchJsonOk(String url) async {
    final response = await _fetch(url);
    if (!response.ok) return null;
    final decoded = json.decode(response.body);
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  /// Recursive tree for a commit or branch ref (Gitea git/trees/{ref}?recursive=1).
  Future<
      ({
        String treeSha,
        List<TreeEntry> tree,
        bool truncated,
      })?> getRecursiveTreeForCommit(String commitSha) async {
    final refs = <String>[
      commitSha,
      branch,
      'refs/heads/$branch',
    ];
    for (final ref in refs.toSet()) {
      final data = await _fetchJsonOk(
        '$_apiBase/repos/$owner/$repo/git/trees/${Uri.encodeComponent(ref)}?recursive=1',
      );
      if (data == null || data['tree'] is! List) continue;
      final entries = (data['tree'] as List).map((e) {
        final m = e as Map<String, dynamic>;
        return TreeEntry(
          path: m['path'] as String,
          mode: (m['mode'] as String?) ?? '100644',
          type: m['type'] as String,
          sha: m['sha'] as String,
          size: m['size'] as int?,
        );
      }).toList();
      return (
        treeSha: _pickSha(data),
        tree: entries,
        truncated: data['truncated'] == true,
      );
    }
    return null;
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
    final gitCommit = await _fetchJsonOk(
      '$_apiBase/repos/$owner/$repo/git/commits/$commitSha',
    );
    if (gitCommit != null) {
      final treeSha = _pickTreeShaFromCommitPayload(gitCommit);
      if (treeSha.isNotEmpty) {
        return CommitInfo(sha: _pickSha(gitCommit), treeSha: treeSha);
      }
    }

    final repoCommit = await _fetchJsonOk(
      '$_apiBase/repos/$owner/$repo/commits/$commitSha',
    );
    if (repoCommit != null) {
      final treeSha = _pickTreeShaFromCommitPayload(repoCommit);
      if (treeSha.isNotEmpty) {
        return CommitInfo(sha: _pickSha(repoCommit), treeSha: treeSha);
      }
    }

    final recursive = await getRecursiveTreeForCommit(commitSha);
    if (recursive != null && recursive.treeSha.isNotEmpty) {
      return CommitInfo(sha: commitSha, treeSha: recursive.treeSha);
    }

    throw GitProviderException(
      'Failed to get commit $commitSha',
      statusCode: 404,
    );
  }

  @override
  Future<String> getCommitTreeSha(String commitSha) async {
    if (_lastCommitSha == commitSha && _lastTreeSha != null) {
      return _lastTreeSha!;
    }

    final recursive = await getRecursiveTreeForCommit(commitSha);
    if (recursive != null && recursive.treeSha.isNotEmpty) {
      _lastCommitSha = commitSha;
      _lastTreeSha = recursive.treeSha;
      return recursive.treeSha;
    }

    final commit = await getCommit(commitSha);
    _lastCommitSha = commitSha;
    _lastTreeSha = commit.treeSha;
    return commit.treeSha;
  }

  @override
  Future<List<TreeEntry>> getTree(String treeSha) async {
    final response = await _fetch(
      '$_apiBase/repos/$owner/$repo/git/trees/${Uri.encodeComponent(treeSha)}?recursive=1',
    );
    if (!response.ok) {
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
        mode: (m['mode'] as String?) ?? '100644',
        type: m['type'] as String,
        sha: m['sha'] as String,
        size: m['size'] as int?,
      );
    }).toList();
  }

  @override
  Future<String> getBlob(String blobSha) async {
    final response = await _fetch(
      '$_apiBase/repos/$owner/$repo/git/blobs/$blobSha',
    );
    if (!response.ok) {
      throw GitProviderException(
        'Failed to get blob $blobSha',
        statusCode: response.statusCode,
      );
    }
    final data = json.decode(response.body) as Map<String, dynamic>;
    return _decodeBase64(data['content'] as String? ?? '');
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
        batch.map((e) async => MapEntry(e.key, await getBlob(e.value))),
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

  Future<String> _createBlob(String content) async {
    final response = await _fetch(
      '$_apiBase/repos/$owner/$repo/git/blobs',
      method: 'POST',
      body: {'content': _encodeBase64(content), 'encoding': 'base64'},
    );
    if (response.statusCode != 201) {
      throw GitProviderException(
        _apiErrorMessage(response.body) ?? 'Failed to create blob',
        statusCode: response.statusCode,
      );
    }
    final data = json.decode(response.body) as Map<String, dynamic>;
    return _pickSha(data);
  }

  Future<String> _createTree(
    String? baseTreeSha,
    List<Map<String, dynamic>> items,
  ) async {
    final body = <String, dynamic>{'tree': items};
    if (baseTreeSha != null && baseTreeSha.isNotEmpty) {
      body['base_tree'] = baseTreeSha;
    }
    final response = await _fetch(
      '$_apiBase/repos/$owner/$repo/git/trees',
      method: 'POST',
      body: body,
    );
    if (response.statusCode != 201) {
      throw GitProviderException(
        _apiErrorMessage(response.body) ?? 'Failed to create tree',
        statusCode: response.statusCode,
      );
    }
    final data = json.decode(response.body) as Map<String, dynamic>;
    return _pickSha(data);
  }

  Future<String> _createCommit(
    String message,
    String treeSha, {
    String? parentSha,
  }) async {
    final response = await _fetch(
      '$_apiBase/repos/$owner/$repo/git/commits',
      method: 'POST',
      body: {
        'message': message,
        'tree': treeSha,
        'parents': parentSha != null ? [parentSha] : <String>[],
      },
    );
    if (response.statusCode != 201) {
      throw GitProviderException(
        _apiErrorMessage(response.body) ?? 'Failed to create commit',
        statusCode: response.statusCode,
      );
    }
    final data = json.decode(response.body) as Map<String, dynamic>;
    return _pickSha(data);
  }

  Future<void> _updateRef(String commitSha) async {
    final response = await _fetch(
      '$_apiBase/repos/$owner/$repo/git/refs/heads/${Uri.encodeComponent(branch)}',
      method: 'PATCH',
      body: {'sha': commitSha},
    );
    if (!response.ok) {
      throw GitProviderException(
        _apiErrorMessage(response.body) ?? 'Failed to update ref',
        statusCode: response.statusCode,
      );
    }
  }

  Future<void> _createRef(String commitSha) async {
    final response = await _fetch(
      '$_apiBase/repos/$owner/$repo/git/refs',
      method: 'POST',
      body: {'ref': 'refs/heads/$branch', 'sha': commitSha},
    );
    if (response.statusCode != 201) {
      throw GitProviderException(
        _apiErrorMessage(response.body) ?? 'Failed to create ref',
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

  bool _shouldFallbackContentsWrite(GitProviderException e) {
    if (_giteaWriteFallbackStatuses.contains(e.statusCode)) return true;
    return e.message.toLowerCase().contains('modified in the meantime');
  }

  Future<Map<String, String>> _getPathShaMap() async {
    try {
      final latestCommitSha = await getLatestCommitSha();
      if (latestCommitSha == null) {
        return {};
      }
      final recursive = await getRecursiveTreeForCommit(latestCommitSha);
      if (recursive == null || recursive.tree.isEmpty) return {};
      final pathToSha = <String, String>{};
      for (final entry in recursive.tree) {
        if (entry.type == 'blob') {
          pathToSha[entry.path] = entry.sha;
        }
      }
      return pathToSha;
    } on GitProviderException catch (e) {
      if (e.statusCode == 404 || e.statusCode == 409) return {};
      rethrow;
    }
  }

  Future<String> _atomicCommitViaGitData(
    String message,
    Map<String, String?> fileChanges,
  ) async {
    Future<String> commitOnExistingBranch(
      String baseTreeSha,
      String parentSha,
      List<List<Map<String, dynamic>>> batches,
    ) async {
      var tree = baseTreeSha;
      var parent = parentSha;
      for (var attempt = 0; attempt < 3; attempt++) {
        final newTreeSha = await _buildLayeredTree(tree, batches);
        final newCommitSha =
            await _createCommit(message, newTreeSha, parentSha: parent);
        try {
          await _updateRef(newCommitSha);
          _lastCommitSha = newCommitSha;
          _lastTreeSha = newTreeSha;
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
    final uploads = <({String path, String content})>[];
    for (final entry in fileChanges.entries) {
      if (entry.value == null) {
        if (!isEmptyRepo) deletions.add(entry.key);
      } else {
        uploads.add((path: entry.key, content: entry.value!));
      }
    }

    if (deletions.isEmpty && uploads.isEmpty) {
      return currentCommitSha ?? '';
    }

    final uploadsWithSha = <ShaTreeUploadEntry>[];
    for (var i = 0; i < uploads.length; i += _blobConcurrency) {
      final chunk = uploads.sublist(
        i,
        i + _blobConcurrency > uploads.length
            ? uploads.length
            : i + _blobConcurrency,
      );
      final chunkResults = await Future.wait(
        chunk.map((u) async {
          final sha = await _createBlob(u.content);
          return ShaTreeUploadEntry(u.path, sha);
        }),
      );
      uploadsWithSha.addAll(chunkResults);
    }

    final batches =
        chunkAtomicCommitShaTreeBatches(deletions, uploadsWithSha);

    if (isEmptyRepo) {
      for (var attempt = 0; attempt < 4; attempt++) {
        final newTreeSha = await _buildLayeredTree(null, batches);
        final newCommitSha = await _createCommit(message, newTreeSha);
        try {
          await _createRef(newCommitSha);
          _lastCommitSha = newCommitSha;
          _lastTreeSha = newTreeSha;
          return newCommitSha;
        } on GitProviderException catch (e) {
          final isConflict = e.statusCode == 409 || e.statusCode == 422;
          if (!isConflict) rethrow;
          try {
            final latestSha = await getLatestCommitSha();
            if (latestSha != null) {
              final fresh = await getCommit(latestSha);
              return commitOnExistingBranch(
                fresh.treeSha,
                fresh.sha,
                batches,
              );
            }
          } catch (_) {
            if (attempt >= 3) rethrow;
          }
        }
      }
      throw GitProviderException(
        'Failed to create initial branch ref after retries',
        statusCode: 409,
      );
    }

    return commitOnExistingBranch(
      currentTreeSha!,
      currentCommitSha!,
      batches,
    );
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

  Future<String> _atomicCommitSequential(
    String message,
    Map<String, String?> fileChanges,
    Map<String, String> pathToSha,
  ) async {
    String? lastCommitSha;
    final sorted = fileChanges.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

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

  @override
  Future<String> atomicCommit(
    String message,
    Map<String, String?> fileChanges,
  ) async {
    if (fileChanges.isEmpty) {
      return (await getLatestCommitSha()) ?? '';
    }

    try {
      return await _atomicCommitViaGitData(message, fileChanges);
    } on GitProviderException catch (e) {
      if (!_shouldFallbackContentsWrite(e)) rethrow;
      final pathToSha =
          await _isEmptyRepo() ? <String, String>{} : await _getPathShaMap();
      return _atomicCommitSequential(message, fileChanges, pathToSha);
    }
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

  /// Fetch bookmark files via Contents API (fallback when git tree read fails).
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
        if (response.statusCode == 403) {
          return TokenValidationResult(valid: true, ambiguous: true);
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
