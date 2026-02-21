import 'dart:convert';

/// GitSyncMarks filename format: {slug-from-title}_{4-char-hash-from-url}.json
String bookmarkFilename(String title, String url) {
  final slug = _slugify(title.isEmpty ? _urlToTitle(url) : title);
  final hash = _shortHash(url);
  return '${slug}_$hash.json';
}

/// Slugify: lowercase, replace spaces/special with dashes, collapse.
String _slugify(String s) {
  if (s.isEmpty) return 'bookmark';
  final normalized = s
      .toLowerCase()
      .replaceAll(RegExp(r'[^\w\s-]'), '')
      .replaceAll(RegExp(r'\s+'), '-')
      .replaceAll(RegExp(r'-+'), '-')
      .trim();
  return normalized.isEmpty ? 'bookmark' : normalized;
}

String _urlToTitle(String url) {
  try {
    final uri = Uri.parse(url);
    final host = uri.host;
    if (host.isNotEmpty) return host;
  } catch (_) {}
  return 'link';
}

/// 4-char hash from URL (hex).
String _shortHash(String url) {
  final bytes = utf8.encode(url);
  var hash = 0;
  for (final b in bytes) {
    hash = ((hash << 5) - hash) + b;
    hash = hash & 0x7FFFFFFF;
  }
  return hash.toRadixString(16).padLeft(4, '0').substring(0, 4);
}
