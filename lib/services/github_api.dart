import 'dart:convert';

import 'package:http/http.dart' as http;

/// Client for GitHub Contents API.
/// Fetches repository contents including directory listings and file contents.
class GithubApi {
  GithubApi({
    required this.token,
    required this.owner,
    required this.repo,
    required this.branch,
    String? basePath,
  }) : basePath = basePath ?? 'bookmarks' {
    _client = http.Client();
  }

  final String token;
  final String owner;
  final String repo;
  final String branch;
  final String basePath;
  late final http.Client _client;

  static const String _baseUrl = 'https://api.github.com';

  /// Fetches the contents of a directory.
  /// Returns list of entries: files (with base64 content) and subdirectories.
  /// Note: Directory listings typically omit file content; use getFileContent for files.
  Future<List<ContentEntry>> getContents(String path) async {
    final pathEncoded =
        path.isEmpty ? path : path.split('/').map((s) => Uri.encodeComponent(s)).join('/');
    final uri = Uri.parse(
      '$_baseUrl/repos/$owner/$repo/contents/$pathEncoded?ref=${Uri.encodeQueryComponent(branch)}',
    );
    final response = await _client.get(
      uri,
      headers: {
        'Accept': 'application/vnd.github+json',
        'Authorization': 'token $token',
        'X-GitHub-Api-Version': '2022-11-28',
      },
    );

    if (response.statusCode != 200) {
      final message = _parseGitHubErrorMessage(response.body) ??
          'Failed to fetch contents: ${response.statusCode}';
      throw GithubApiException(
        message,
        statusCode: response.statusCode,
        body: response.body,
      );
    }

    final decoded = json.decode(response.body);
    if (decoded is! List) {
      throw GithubApiException('Expected list response for directory');
    }

    return decoded
        .map<ContentEntry>((e) => ContentEntry(
              name: e['name'] as String,
              type: e['type'] as String,
              path: e['path'] as String?,
              content: e['content'] as String?,
              encoding: e['encoding'] as String?,
            ))
        .toList();
  }

  /// Parses GitHub API error response for user-facing message.
  static String? _parseGitHubErrorMessage(String? body) {
    if (body == null || body.isEmpty) return null;
    try {
      final decoded = json.decode(body) as Map<String, dynamic>?;
      final msg = decoded?['message'] as String?;
      return msg?.trim().isNotEmpty == true ? msg : null;
    } catch (_) {
      return null;
    }
  }

  /// Fetches a single file's content. Uses standard API (base64) for auth compatibility.
  Future<String> getFileContent(String path) async {
    final pathEncoded = path.isEmpty
        ? path
        : path.split('/').map((s) => Uri.encodeComponent(s)).join('/');
    final uri = Uri.parse(
      '$_baseUrl/repos/$owner/$repo/contents/$pathEncoded?ref=${Uri.encodeQueryComponent(branch)}',
    );
    final response = await _client.get(
      uri,
      headers: {
        'Accept': 'application/vnd.github+json',
        'Authorization': 'token $token',
        'X-GitHub-Api-Version': '2022-11-28',
      },
    );

    if (response.statusCode != 200) {
      final message = _parseGitHubErrorMessage(response.body) ??
          'Failed to fetch file: ${response.statusCode}';
      throw GithubApiException(
        message,
        statusCode: response.statusCode,
        body: response.body,
      );
    }

    final decoded = json.decode(response.body) as Map<String, dynamic>;
    final content = decoded['content'] as String?;
    final encoding = decoded['encoding'] as String?;
    if (content == null) {
      throw GithubApiException('File has no content');
    }
    return encoding == 'base64' ? decodeContent(content) : content;
  }

  /// Decodes base64 content to string.
  String decodeContent(String base64Content) {
    return utf8.decode(base64.decode(base64Content.replaceAll('\n', '')));
  }

  /// Encodes string content to base64 (for API requests).
  String encodeContent(String content) {
    return base64.encode(utf8.encode(content));
  }

  /// Creates or updates a file in the repository.
  /// [path] is relative to repo root (e.g. "bookmarks/toolbar/file.json").
  /// [content] is the raw file content (will be base64-encoded).
  /// [message] is the commit message.
  /// [sha] is required when updating an existing file (get from GET contents response).
  /// Returns the new file's sha and commit sha.
  Future<CreateOrUpdateResult> createOrUpdateFile(
    String path,
    String content,
    String message, {
    String? sha,
  }) async {
    final pathEncoded = path
        .split('/')
        .map((s) => Uri.encodeComponent(s))
        .join('/');
    final uri = Uri.parse('$_baseUrl/repos/$owner/$repo/contents/$pathEncoded');

    final body = <String, dynamic>{
      'message': message,
      'content': encodeContent(content),
      'branch': branch,
    };
    if (sha != null && sha.isNotEmpty) {
      body['sha'] = sha;
    }

    final response = await _client.put(
      uri,
      headers: {
        'Accept': 'application/vnd.github+json',
        'Authorization': 'token $token',
        'X-GitHub-Api-Version': '2022-11-28',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final message = _parseGitHubErrorMessage(response.body) ??
          'Failed to write file: ${response.statusCode}';
      throw GithubApiException(
        message,
        statusCode: response.statusCode,
        body: response.body,
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

  /// Deletes a file from the repository.
  /// [path] is relative to repo root (e.g. "bookmarks/toolbar/file.json").
  /// [sha] is required (get from getFileMeta).
  Future<void> deleteFile(String path, String sha, String message) async {
    final pathEncoded = path
        .split('/')
        .map((s) => Uri.encodeComponent(s))
        .join('/');
    final uri = Uri.parse('$_baseUrl/repos/$owner/$repo/contents/$pathEncoded');

    final response = await _client.delete(
      uri,
      headers: {
        'Accept': 'application/vnd.github+json',
        'Authorization': 'token $token',
        'X-GitHub-Api-Version': '2022-11-28',
        'Content-Type': 'application/json',
      },
      body: json.encode(<String, dynamic>{
        'message': message,
        'sha': sha,
        'branch': branch,
      }),
    );

    if (response.statusCode != 200) {
      final errMsg = _parseGitHubErrorMessage(response.body) ??
          'Failed to delete file: ${response.statusCode}';
      throw GithubApiException(
        errMsg,
        statusCode: response.statusCode,
        body: response.body,
      );
    }
  }

  /// Fetches a file's metadata including sha (for updates).
  /// Returns null if file does not exist.
  Future<FileMeta?> getFileMeta(String path) async {
    final pathEncoded = path
        .split('/')
        .map((s) => Uri.encodeComponent(s))
        .join('/');
    final uri = Uri.parse(
      '$_baseUrl/repos/$owner/$repo/contents/$pathEncoded?ref=${Uri.encodeQueryComponent(branch)}',
    );
    final response = await _client.get(
      uri,
      headers: {
        'Accept': 'application/vnd.github+json',
        'Authorization': 'token $token',
        'X-GitHub-Api-Version': '2022-11-28',
      },
    );
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) {
      final message = _parseGitHubErrorMessage(response.body) ??
          'Failed to fetch file: ${response.statusCode}';
      throw GithubApiException(
        message,
        statusCode: response.statusCode,
        body: response.body,
      );
    }
    final decoded = json.decode(response.body) as Map<String, dynamic>;
    return FileMeta(sha: decoded['sha'] as String?);
  }

  void close() {
    _client.close();
  }
}

/// Result of createOrUpdateFile.
class CreateOrUpdateResult {
  CreateOrUpdateResult({this.contentSha, this.commitSha});

  final String? contentSha;
  final String? commitSha;
}

/// File metadata from GitHub API.
class FileMeta {
  FileMeta({this.sha});

  final String? sha;
}

/// Single entry from GitHub Contents API (file or directory).
class ContentEntry {
  ContentEntry({
    required this.name,
    required this.type,
    this.path,
    this.content,
    this.encoding,
  });

  final String name;
  final String type; // "file" or "dir"
  /// Full path from repo root (e.g. "bookmarks/toolbar/file.json").
  final String? path;
  final String? content;
  final String? encoding;
}

class GithubApiException implements Exception {
  GithubApiException(this.message, {this.statusCode, this.body});

  final String message;
  final int? statusCode;
  final String? body;

  @override
  String toString() => 'GithubApiException: $message';
}
