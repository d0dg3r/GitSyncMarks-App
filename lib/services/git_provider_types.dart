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

/// Result of createOrUpdateFile via Contents API.
class CreateOrUpdateResult {
  CreateOrUpdateResult({this.contentSha, this.commitSha});

  final String? contentSha;
  final String? commitSha;
}

/// File metadata from Contents API.
class FileMeta {
  FileMeta({this.sha});

  final String? sha;
}

/// Single entry from Contents API (file or directory).
class ContentEntry {
  ContentEntry({
    required this.name,
    required this.type,
    this.path,
    this.content,
    this.encoding,
    this.sha,
  });

  final String name;
  final String type;
  final String? path;
  final String? content;
  final String? encoding;
  final String? sha;
}

/// Token validation result.
class TokenValidationResult {
  TokenValidationResult({
    required this.valid,
    this.username,
    this.scopes = const [],
    this.ambiguous = false,
  });

  final bool valid;
  final String? username;
  final List<String> scopes;
  final bool ambiguous;
}
