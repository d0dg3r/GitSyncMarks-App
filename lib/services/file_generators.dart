import 'dart:convert';

import 'bookmark_parser.dart';

/// Display names for root folder roles.
const Map<String, String> _roleDisplayNames = {
  'toolbar': 'Bookmarks Bar',
  'other': 'Other Bookmarks',
};

// =============================================================================
// README.md (Markdown)
// =============================================================================

/// Generates a README.md with bookmark links (Markdown format).
String generateReadme(Map<String, String> files, String basePath) {
  final base = basePath.replaceAll(RegExp(r'/+$'), '');
  final lines = <String>[
    '# Bookmarks',
    '',
    '> Last synced: ${DateTime.now().toUtc().toIso8601String()}',
    '',
    '> Import: Download `bookmarks.html` and import it in your browser (Chrome: Bookmarks → Import; Firefox: Import and Backup → Import Bookmarks from file).',
    '',
  ];

  for (final role in syncRoles) {
    final orderPath = '$base/$role/_order.json';
    if (!files.containsKey(orderPath)) continue;

    final displayName = _roleDisplayNames[role] ?? role;
    lines.add('## $displayName');
    lines.add('');
    _renderFolderAsMarkdown(files, '$base/$role', lines, 3);
    lines.add('');
  }

  return lines.join('\n');
}

void _renderFolderAsMarkdown(
  Map<String, String> files,
  String dirPath,
  List<String> lines,
  int headingLevel,
) {
  final order = _parseOrderJson(files, dirPath);
  if (order == null) return;

  final classified = _classifyOrderEntries(order);

  for (final filename in classified.bookmarkEntries) {
    final content = files['$dirPath/$filename'];
    if (content == null) continue;
    try {
      final data = json.decode(content) as Map<String, dynamic>;
      final title = (data['title'] as String?) ?? (data['url'] as String?) ?? 'Untitled';
      lines.add('- [$title](${data['url']})');
    } catch (_) {}
  }

  if (classified.bookmarkEntries.isNotEmpty && classified.folderEntries.isNotEmpty) {
    lines.add('');
  }

  for (final folder in classified.folderEntries) {
    final folderPath = '$dirPath/${folder['dir']}';
    if (!files.containsKey('$folderPath/_order.json')) continue;
    final prefix = '#' * headingLevel.clamp(1, 6);
    final title = (folder['title'] as String?) ?? folder['dir'] as String;
    lines.add('$prefix $title');
    lines.add('');
    _renderFolderAsMarkdown(files, folderPath, lines, headingLevel + 1);
  }
}

// =============================================================================
// bookmarks.html (Netscape HTML)
// =============================================================================

/// Generates a Netscape HTML bookmark file for browser import.
String generateBookmarksHtml(Map<String, String> files, String basePath) {
  final base = basePath.replaceAll(RegExp(r'/+$'), '');
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final parts = <String>[
    '<!DOCTYPE NETSCAPE-Bookmark-file-1>',
    '<!-- This is an automatically generated file. Do not edit. -->',
    '<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">',
    '<TITLE>Bookmarks</TITLE>',
    '<H1>Bookmarks</H1>',
    '<DL><p>',
  ];

  for (final role in syncRoles) {
    if (!files.containsKey('$base/$role/_order.json')) continue;
    final displayName = _roleDisplayNames[role] ?? role;
    parts.add('    <DT><H3 FOLDED ADD_DATE="$now">${_escapeHtml(displayName)}</H3>');
    parts.add('    <DL><p>');
    _renderFolderAsHtml(files, '$base/$role', parts, now);
    parts.add('    </DL><p>');
  }

  parts.add('</DL><p>');
  return parts.join('\n');
}

void _renderFolderAsHtml(
  Map<String, String> files,
  String dirPath,
  List<String> parts,
  int defaultDate,
) {
  final order = _parseOrderJson(files, dirPath);
  if (order == null) return;

  final classified = _classifyOrderEntries(order);

  for (final filename in classified.bookmarkEntries) {
    final content = files['$dirPath/$filename'];
    if (content == null) continue;
    try {
      final data = json.decode(content) as Map<String, dynamic>;
      if (data['url'] == null) continue;
      final title =
          _escapeHtml((data['title'] as String?) ?? (data['url'] as String?) ?? 'Untitled');
      final url = _escapeHtml(data['url'] as String);
      parts.add('        <DT><A HREF="$url" ADD_DATE="$defaultDate">$title</A>');
    } catch (_) {}
  }

  for (final folder in classified.folderEntries) {
    final folderPath = '$dirPath/${folder['dir']}';
    if (!files.containsKey('$folderPath/_order.json')) continue;
    final title =
        _escapeHtml((folder['title'] as String?) ?? folder['dir'] as String);
    parts.add('        <DT><H3 FOLDED ADD_DATE="$defaultDate">$title</H3>');
    parts.add('        <DL><p>');
    _renderFolderAsHtml(files, folderPath, parts, defaultDate);
    parts.add('        </DL><p>');
  }
}

// =============================================================================
// feed.xml (RSS 2.0)
// =============================================================================

/// Generates an RSS 2.0 feed of all bookmarks.
String generateFeedXml(Map<String, String> files, String basePath) {
  final base = basePath.replaceAll(RegExp(r'/+$'), '');
  final now = DateTime.now().toUtc().toIso8601String();
  final items = <_RssItem>[];

  for (final role in syncRoles) {
    if (!files.containsKey('$base/$role/_order.json')) continue;
    final displayName = _roleDisplayNames[role] ?? role;
    _collectRssItems(files, '$base/$role', displayName, items);
  }

  final lines = <String>[
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<rss version="2.0">',
    '  <channel>',
    '    <title>Bookmarks</title>',
    '    <description>Bookmarks synced by GitSyncMarks</description>',
    '    <lastBuildDate>${_escapeXml(now)}</lastBuildDate>',
    '    <generator>GitSyncMarks</generator>',
  ];

  for (final item in items) {
    lines.add('    <item>');
    lines.add('      <title>${_escapeXml(item.title)}</title>');
    lines.add('      <link>${_escapeXml(item.url)}</link>');
    lines.add('      <category>${_escapeXml(item.category)}</category>');
    lines.add('    </item>');
  }

  lines.add('  </channel>');
  lines.add('</rss>');
  return lines.join('\n');
}

void _collectRssItems(
  Map<String, String> files,
  String dirPath,
  String categoryPath,
  List<_RssItem> items,
) {
  final order = _parseOrderJson(files, dirPath);
  if (order == null) return;

  final classified = _classifyOrderEntries(order);

  for (final filename in classified.bookmarkEntries) {
    final content = files['$dirPath/$filename'];
    if (content == null) continue;
    try {
      final data = json.decode(content) as Map<String, dynamic>;
      if (data['url'] == null) continue;
      items.add(_RssItem(
        title: (data['title'] as String?) ?? data['url'] as String,
        url: data['url'] as String,
        category: categoryPath,
      ));
    } catch (_) {}
  }

  for (final folder in classified.folderEntries) {
    final folderPath = '$dirPath/${folder['dir']}';
    if (!files.containsKey('$folderPath/_order.json')) continue;
    final title = (folder['title'] as String?) ?? folder['dir'] as String;
    _collectRssItems(files, folderPath, '$categoryPath / $title', items);
  }
}

// =============================================================================
// dashy-conf.yml (Dashy YAML)
// =============================================================================

/// Generates a Dashy dashboard YAML configuration.
String generateDashyYaml(Map<String, String> files, String basePath) {
  final base = basePath.replaceAll(RegExp(r'/+$'), '');
  final sections = <_DashySection>[];

  for (final role in syncRoles) {
    if (!files.containsKey('$base/$role/_order.json')) continue;
    final displayName = _roleDisplayNames[role] ?? role;
    _collectDashySections(files, '$base/$role', displayName, sections);
  }

  if (sections.isEmpty) return 'sections: []\n';

  final lines = <String>['sections:'];
  for (final section in sections) {
    lines.add('  - name: ${_yamlQuote(section.name)}');
    if (section.items.isEmpty) {
      lines.add('    items: []');
    } else {
      lines.add('    items:');
      for (final item in section.items) {
        lines.add('      - title: ${_yamlQuote(item.title)}');
        lines.add('        url: ${_yamlQuote(item.url)}');
        lines.add('        icon: favicon');
      }
    }
  }

  return '${lines.join('\n')}\n';
}

void _collectDashySections(
  Map<String, String> files,
  String dirPath,
  String sectionName,
  List<_DashySection> sections,
) {
  final order = _parseOrderJson(files, dirPath);
  if (order == null) return;

  final classified = _classifyOrderEntries(order);
  final bookmarks = <_DashyItem>[];

  for (final filename in classified.bookmarkEntries) {
    final content = files['$dirPath/$filename'];
    if (content == null) continue;
    try {
      final data = json.decode(content) as Map<String, dynamic>;
      if (data['url'] == null) continue;
      bookmarks.add(_DashyItem(
        title: (data['title'] as String?) ?? data['url'] as String,
        url: data['url'] as String,
      ));
    } catch (_) {}
  }

  sections.add(_DashySection(name: sectionName, items: bookmarks));

  for (final folder in classified.folderEntries) {
    final folderPath = '$dirPath/${folder['dir']}';
    if (!files.containsKey('$folderPath/_order.json')) continue;
    final title = (folder['title'] as String?) ?? folder['dir'] as String;
    _collectDashySections(files, folderPath, '$sectionName > $title', sections);
  }
}

// =============================================================================
// Convenience: add generated files to a file-changes map
// =============================================================================

/// Generation modes: off, manual, auto.
enum GenMode { off, manual, auto }

/// Parses a generation mode string.
GenMode parseGenMode(dynamic value) {
  if (value == true) return GenMode.auto;
  if (value == false) return GenMode.off;
  switch (value) {
    case 'auto':
      return GenMode.auto;
    case 'manual':
      return GenMode.manual;
    default:
      return GenMode.off;
  }
}

/// Settings for which generated files to produce and in which mode.
class GeneratedFilesConfig {
  GeneratedFilesConfig({
    this.readmeMd = GenMode.off,
    this.bookmarksHtml = GenMode.off,
    this.feedXml = GenMode.off,
    this.dashyYml = GenMode.off,
  });

  GenMode readmeMd;
  GenMode bookmarksHtml;
  GenMode feedXml;
  GenMode dashyYml;

  bool get anyEnabled =>
      readmeMd != GenMode.off ||
      bookmarksHtml != GenMode.off ||
      feedXml != GenMode.off ||
      dashyYml != GenMode.off;
}

/// Adds generated file contents to [fileChanges] according to the config.
///
/// [threshold] controls which modes trigger generation:
/// - `auto` (default): only files with mode == auto
/// - `notOff`: files with mode != off (for "Generate Now" button)
void addGeneratedFiles(
  Map<String, String?> fileChanges,
  Map<String, String> sourceFiles,
  String basePath, {
  required GeneratedFilesConfig config,
  String threshold = 'auto',
}) {
  bool check(GenMode m) =>
      threshold == 'auto' ? m == GenMode.auto : m != GenMode.off;

  if (check(config.readmeMd)) {
    fileChanges['$basePath/README.md'] = generateReadme(sourceFiles, basePath);
  }
  if (check(config.bookmarksHtml)) {
    fileChanges['$basePath/bookmarks.html'] =
        generateBookmarksHtml(sourceFiles, basePath);
  }
  if (check(config.feedXml)) {
    fileChanges['$basePath/feed.xml'] = generateFeedXml(sourceFiles, basePath);
  }
  if (check(config.dashyYml)) {
    fileChanges['$basePath/dashy-conf.yml'] =
        generateDashyYaml(sourceFiles, basePath);
  }
}

// =============================================================================
// Shared helpers
// =============================================================================

List<dynamic>? _parseOrderJson(Map<String, String> files, String dirPath) {
  final content = files['$dirPath/_order.json'];
  if (content == null) return null;
  try {
    final decoded = json.decode(content);
    return decoded is List ? decoded : null;
  } catch (_) {
    return null;
  }
}

_ClassifiedEntries _classifyOrderEntries(List<dynamic> order) {
  final bookmarks = <String>[];
  final folders = <Map<String, dynamic>>[];

  for (final entry in order) {
    if (entry is String && entry.endsWith('.json')) {
      bookmarks.add(entry);
    } else if (entry is Map) {
      folders.add(Map<String, dynamic>.from(entry));
    } else if (entry is String) {
      folders.add({'dir': entry, 'title': entry});
    }
  }

  return _ClassifiedEntries(bookmarkEntries: bookmarks, folderEntries: folders);
}

String _escapeHtml(String str) {
  return str
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
}

String _escapeXml(String str) {
  return str
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&apos;');
}

String _yamlQuote(String str) {
  if (str.isEmpty) return '""';
  if (str.contains('\n') || str.contains('\r')) return json.encode(str);
  if (RegExp(r'[:#\[\]{}&*!|>''"%@`,?]').hasMatch(str) ||
      str != str.trim()) {
    return json.encode(str);
  }
  return str;
}

class _ClassifiedEntries {
  _ClassifiedEntries({required this.bookmarkEntries, required this.folderEntries});
  final List<String> bookmarkEntries;
  final List<Map<String, dynamic>> folderEntries;
}

class _RssItem {
  _RssItem({required this.title, required this.url, required this.category});
  final String title;
  final String url;
  final String category;
}

class _DashySection {
  _DashySection({required this.name, required this.items});
  final String name;
  final List<_DashyItem> items;
}

class _DashyItem {
  _DashyItem({required this.title, required this.url});
  final String title;
  final String url;
}
