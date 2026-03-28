import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WhatsNewEntry {
  const WhatsNewEntry({required this.version, required this.items});

  final String version;
  final List<String> items;
}

const _kLastSeenVersionKey = 'whats_new_last_seen_version';

const List<WhatsNewEntry> whatsNewEntries = [
  WhatsNewEntry(
    version: '0.3.5',
    items: [
      'Atomic Git commits via Git Data API',
      'Three-way merge sync with conflict resolution',
      'Sync history: view, diff, restore, undo',
      'Edit bookmarks, create folders inline',
      'Generated files (README, HTML, RSS, Dashy)',
      'UI density (S / M / L)',
      'Sync on app resume',
      'Debug log with export',
      'GitHub Repos and Linkwarden virtual folders (optional)',
      'Export as HTML, RSS, Dashy YAML, Markdown',
    ],
  ),
];

class WhatsNewService {
  static Future<WhatsNewEntry?> checkForNew() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSeen = prefs.getString(_kLastSeenVersionKey);
    final info = await PackageInfo.fromPlatform();
    final current = info.version;

    if (lastSeen == current) return null;

    final entry = whatsNewEntries
        .where((e) => e.version == current)
        .firstOrNull;

    if (entry == null && lastSeen == null) {
      await prefs.setString(_kLastSeenVersionKey, current);
      return null;
    }

    return entry;
  }

  static Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    final info = await PackageInfo.fromPlatform();
    await prefs.setString(_kLastSeenVersionKey, info.version);
  }

  static Future<void> showWhatsNewDialog(
    BuildContext context,
    WhatsNewEntry entry,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("What's New in ${entry.version}"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: entry.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (_, i) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 16)),
                Expanded(
                  child: Text(
                    entry.items[i],
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              markSeen();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
