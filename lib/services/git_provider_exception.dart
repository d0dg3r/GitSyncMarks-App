class GitProviderException implements Exception {
  GitProviderException(this.message, {this.statusCode, this.body});

  final String message;
  final int? statusCode;
  final String? body;

  @override
  String toString() => 'GitProviderException($statusCode): $message';
}

/// Backward-compatible alias.
typedef GitDataApiException = GitProviderException;

typedef GithubApiException = GitProviderException;
