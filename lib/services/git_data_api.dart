import 'dart:convert';

import 'package:http/http.dart' as http;

/// Entry from a Git tree (recursive listing).
class TreeEntry {
  TreeEntry({
    required this.path,
    required this.mode,
    required this.type,
    required this.sha,
    this.size,
  });

  final String path;
  final String mode;
  final String type;
  final String sha;
  final int? size;
}

/// Commit metadata from the Git Data API.
class CommitInfo {
  CommitInfo({required this.sha, required this.treeSha});

  final String sha;
  final String treeSha;
}

/// Entry from the commits list endpoint.
class CommitEntry {
  CommitEntry({
    required this.sha,
    required this.message,
    required this.date,
    required this.author,
  });

  final String sha;
  final String message;
  final String date;
  final String author;
}

class GitDataApiException implements Exception {
  GitDataApiException(this.message, {this.statusCode, this.body});

  final String message;
  final int? statusCode;
  final String? body;

  @override
  String toString() => 'GitDataApiException($statusCode): $message';
}

/// GitHub Git Data API client for atomic multi-file operations.
///
/// Uses the low-level Git endpoints (blobs, trees, commits, refs) to read the
/// full repo tree in a handful of requests and write multiple file changes in a
/// single atomic commit.
class GitDataApi {
  GitDataApi({
    required this.token,
    required this.owner,
    required this.repo,
    required this.branch,
  }) : _client = http.Client();

  final String token;
  final String owner;
  final String repo;
  final String branch;
  final http.Client _client;

  static const String _baseUrl = 'https://api.github.com';
  static const int _blobConcurrency = 5;

  Map<String, String> get _headers => {
        'Accept': 'application/vnd.github.v3+json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'X-GitHub-Api-Version': '2022-11-28',
      };

  Future<http.Response> _request(
    String url, {
    String method = 'GET',
    Object? body,
  }) async {
    final uri = Uri.parse(url);
    final encodedBody = body != null ? json.encode(body) : null;

    late http.Response response;
    switch (method) {
      case 'POST':
        response =
            await _client.post(uri, headers: _headers, body: encodedBody);
      case 'PATCH':
        response =
            await _client.patch(uri, headers: _headers, body: encodedBody);
      default:
        response = await _client.get(uri, headers: _headers);
    }

    if (response.statusCode == 401) {
      throw GitDataApiException('Invalid token', statusCode: 401);
    }
    if (response.statusCode == 429) {
      throw GitDataApiException('Rate limit exceeded', statusCode: 429);
    }
    if (response.statusCode == 403) {
      final data = _tryParseJson(response.body);
      if (data?['message']?.toString().contains('rate limit') == true) {
        throw GitDataApiException('Rate limit exceeded', statusCode: 403);
      }
      throw GitDataApiException('Access denied', statusCode: 403);
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

  // ---------------------------------------------------------------------------
  // Read operations
  // ---------------------------------------------------------------------------

  /// Returns the HEAD commit SHA for [branch], or `null` for empty repos.
  Future<String?> getLatestCommitSha() async {
    final branchEnc = Uri.encodeComponent(branch);
    final response = await _request(
      '$_baseUrl/repos/$owner/$repo/git/ref/heads/$branchEnc',
    );
    if (response.statusCode == 404 || response.statusCode == 409) {
      return null;
    }
    if (response.statusCode != 200) {
      throw GitDataApiException(
        'Branch not found: $branch',
        statusCode: response.statusCode,
      );
    }
    final data = json.decode(response.body) as Map<String, dynamic>;
    return (data['object'] as Map<String, dynamic>)['sha'] as String;
  }

  Future<CommitInfo> getCommit(String commitSha) async {
    final response = await _request(
      '$_baseUrl/repos/$owner/$repo/git/commits/$commitSha',
    );
    if (response.statusCode != 200) {
      throw GitDataApiException(
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

  Future<List<TreeEntry>> getTree(String treeSha) async {
    final response = await _request(
      '$_baseUrl/repos/$owner/$repo/git/trees/$treeSha?recursive=1',
    );
    if (response.statusCode != 200) {
      throw GitDataApiException(
        'Failed to get tree $treeSha',
        statusCode: response.statusCode,
      );
    }
    final data = json.decode(response.body) as Map<String, dynamic>;
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

  Future<String> getBlob(String blobSha) async {
    final response = await _request(
      '$_baseUrl/repos/$owner/$repo/git/blobs/$blobSha',
    );
    if (response.statusCode != 200) {
      throw GitDataApiException(
        'Failed to get blob $blobSha',
        statusCode: response.statusCode,
      );
    }
    final data = json.decode(response.body) as Map<String, dynamic>;
    return _decodeBase64Content(data['content'] as String);
  }

  /// Fetches multiple blobs in batches, reusing cached content when SHA matches.
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

  /// Lists recent commits, optionally filtered by [path].
  Future<List<CommitEntry>> listCommits({
    String? path,
    int perPage = 20,
  }) async {
    final branchEnc = Uri.encodeComponent(branch);
    var url =
        '$_baseUrl/repos/$owner/$repo/commits?sha=$branchEnc&per_page=$perPage';
    if (path != null) url += '&path=${Uri.encodeComponent(path)}';

    final response = await _request(url);
    if (response.statusCode != 200) {
      throw GitDataApiException(
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

  // ---------------------------------------------------------------------------
  // Write operations
  // ---------------------------------------------------------------------------

  Future<String> createBlob(String content) async {
    final response = await _request(
      '$_baseUrl/repos/$owner/$repo/git/blobs',
      method: 'POST',
      body: {'content': content, 'encoding': 'utf-8'},
    );
    if (response.statusCode != 201) {
      throw GitDataApiException(
        'Failed to create blob',
        statusCode: response.statusCode,
      );
    }
    final data = json.decode(response.body) as Map<String, dynamic>;
    return data['sha'] as String;
  }

  Future<String> createTree(
    String? baseTreeSha,
    List<Map<String, dynamic>> items,
  ) async {
    final body = <String, dynamic>{'tree': items};
    if (baseTreeSha != null) body['base_tree'] = baseTreeSha;

    final response = await _request(
      '$_baseUrl/repos/$owner/$repo/git/trees',
      method: 'POST',
      body: body,
    );
    if (response.statusCode != 201) {
      final err = _tryParseJson(response.body);
      throw GitDataApiException(
        'Failed to create tree: ${err?['message'] ?? response.statusCode}',
        statusCode: response.statusCode,
      );
    }
    final data = json.decode(response.body) as Map<String, dynamic>;
    return data['sha'] as String;
  }

  Future<String> createCommit(
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
      '$_baseUrl/repos/$owner/$repo/git/commits',
      method: 'POST',
      body: body,
    );
    if (response.statusCode != 201) {
      throw GitDataApiException(
        'Failed to create commit',
        statusCode: response.statusCode,
      );
    }
    final data = json.decode(response.body) as Map<String, dynamic>;
    return data['sha'] as String;
  }

  Future<void> updateRef(String commitSha) async {
    final branchEnc = Uri.encodeComponent(branch);
    final response = await _request(
      '$_baseUrl/repos/$owner/$repo/git/refs/heads/$branchEnc',
      method: 'PATCH',
      body: {'sha': commitSha},
    );
    if (response.statusCode != 200) {
      final err = _tryParseJson(response.body);
      throw GitDataApiException(
        'Failed to update ref: ${err?['message'] ?? response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  Future<void> createRef(String commitSha) async {
    final response = await _request(
      '$_baseUrl/repos/$owner/$repo/git/refs',
      method: 'POST',
      body: {'ref': 'refs/heads/$branch', 'sha': commitSha},
    );
    if (response.statusCode != 201) {
      throw GitDataApiException(
        'Failed to create ref',
        statusCode: response.statusCode,
      );
    }
  }

  /// Atomic multi-file commit via the Git Data API.
  ///
  /// [fileChanges] maps file paths to content strings. A `null` value deletes
  /// the file. All changes are applied in a single commit.
  ///
  /// Returns the SHA of the new commit, or the current HEAD SHA when
  /// [fileChanges] produces no tree items.
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
    } on GitDataApiException catch (e) {
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

    final treeItems = <Map<String, dynamic>>[
      for (final path in deletions)
        {'path': path, 'mode': '100644', 'type': 'blob', 'sha': null},
    ];

    for (var i = 0; i < uploads.length; i += _blobConcurrency) {
      final end = (i + _blobConcurrency).clamp(0, uploads.length);
      final batch = uploads.sublist(i, end);
      final results = await Future.wait(
        batch.map((u) async {
          final sha = await createBlob(u.content);
          return {'path': u.path, 'mode': '100644', 'type': 'blob', 'sha': sha};
        }),
      );
      treeItems.addAll(results);
    }

    if (treeItems.isEmpty) return currentCommitSha ?? '';

    if (isEmptyRepo) {
      return _commitOnEmptyRepo(message, treeItems);
    }
    return _commitOnExistingBranch(
      message,
      treeItems,
      currentTreeSha!,
      currentCommitSha!,
    );
  }

  Future<String> _commitOnExistingBranch(
    String message,
    List<Map<String, dynamic>> treeItems,
    String baseTreeSha,
    String parentSha,
  ) async {
    var tree = baseTreeSha;
    var parent = parentSha;

    for (var attempt = 0; attempt < 3; attempt++) {
      final newTreeSha = await createTree(tree, treeItems);
      final newCommitSha =
          await createCommit(message, newTreeSha, parentSha: parent);
      try {
        await updateRef(newCommitSha);
        return newCommitSha;
      } on GitDataApiException catch (e) {
        final isConflict = e.statusCode == 409 || e.statusCode == 422;
        if (!isConflict || attempt >= 2) rethrow;

        final freshSha = await getLatestCommitSha();
        if (freshSha == null) rethrow;
        final freshCommit = await getCommit(freshSha);
        tree = freshCommit.treeSha;
        parent = freshCommit.sha;
      }
    }
    throw GitDataApiException(
      'Failed to update ref after retries',
      statusCode: 409,
    );
  }

  Future<String> _commitOnEmptyRepo(
    String message,
    List<Map<String, dynamic>> treeItems,
  ) async {
    for (var attempt = 0; attempt < 4; attempt++) {
      final newTreeSha = await createTree(null, treeItems);
      final newCommitSha = await createCommit(message, newTreeSha);
      try {
        await createRef(newCommitSha);
        return newCommitSha;
      } on GitDataApiException catch (e) {
        final isConflict = e.statusCode == 409 || e.statusCode == 422;
        if (!isConflict) rethrow;

        try {
          final latestSha = await getLatestCommitSha();
          if (latestSha != null) {
            final fresh = await getCommit(latestSha);
            return _commitOnExistingBranch(
              message,
              treeItems,
              fresh.treeSha,
              fresh.sha,
            );
          }
        } on GitDataApiException {
          if (attempt >= 3) rethrow;
        }
      }
    }
    throw GitDataApiException(
      'Failed to create initial branch ref after retries',
      statusCode: 409,
    );
  }

  void close() => _client.close();
}

/// A file entry in the sync-state base snapshot.
class SyncFileEntry {
  SyncFileEntry({required this.sha, required this.content});

  factory SyncFileEntry.fromJson(Map<String, dynamic> json) => SyncFileEntry(
        sha: json['sha'] as String,
        content: json['content'] as String,
      );

  final String sha;
  final String content;

  Map<String, dynamic> toJson() => {'sha': sha, 'content': content};
}

class _UploadEntry {
  _UploadEntry(this.path, this.content);
  final String path;
  final String content;
}
