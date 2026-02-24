import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/profile.dart';
import 'settings_crypto.dart';
import 'web_download_stub.dart'
    if (dart.library.html) 'web_download_web.dart';

/// Result of parsing a GitSyncMarks settings JSON file.
class ImportResult {
  ImportResult({
    required this.profiles,
    required this.activeProfileId,
    this.syncSettingsToGit,
    this.settingsSyncMode,
  });

  final List<Profile> profiles;
  final String activeProfileId;
  /// From JSON if present (for apply on import/pull).
  final bool? syncSettingsToGit;
  final String? settingsSyncMode;
}

/// Handles import / export of GitSyncMarks settings JSON.
///
/// The JSON format is compatible with the GitSyncMarks browser extension
/// "Export Settings" / "Import Settings" feature.
class SettingsImportExportService {
  /// Parses a GitSyncMarks settings JSON string into a list of profiles.
  /// Works with both the extension's multi-profile format and the legacy
  /// flat format (single `repoOwner` / `githubToken` at root level).
  ImportResult parseSettingsJson(String jsonString) {
    final data = json.decode(jsonString) as Map<String, dynamic>;

    final profiles = <Profile>[];

    if (data.containsKey('profiles') && data['profiles'] is Map) {
      final profilesMap = data['profiles'] as Map<String, dynamic>;
      for (final entry in profilesMap.entries) {
        final profileData = entry.value as Map<String, dynamic>;
        profileData['id'] ??= entry.key;
        profiles.add(Profile.fromJson(profileData));
      }
    } else {
      // Legacy flat format.
      profiles.add(Profile.fromJson({
        'id': 'default',
        'name': 'Default',
        'token': data['githubToken'] ?? data['token'] ?? '',
        'owner': data['repoOwner'] ?? data['owner'] ?? '',
        'repo': data['repoName'] ?? data['repo'] ?? '',
        'branch': data['branch'] ?? 'main',
        'filePath': data['filePath'] ?? data['basePath'] ?? 'bookmarks',
      }));
    }

    if (profiles.isEmpty) {
      throw const FormatException('No profiles found in settings file');
    }

    final activeId =
        (data['activeProfileId'] as String?) ?? profiles.first.id;
    final syncSettingsToGit = data['syncSettingsToGit'] as bool?;
    final settingsSyncMode = data['settingsSyncMode'] as String?;

    return ImportResult(
      profiles: profiles,
      activeProfileId: activeId,
      syncSettingsToGit: syncSettingsToGit,
      settingsSyncMode: (settingsSyncMode == 'global' || settingsSyncMode == 'individual')
          ? settingsSyncMode
          : null,
    );
  }

  /// Builds a JSON string from the given profiles, compatible with the
  /// GitSyncMarks browser extension import format.
  ///
  /// [activeProfile] can be provided to add extension-compatible globals
  /// (autoSync, syncInterval, syncProfile, syncOnStart) from the active profile.
  String buildExportJson(
    List<Profile> profiles,
    String activeProfileId, {
    Profile? activeProfile,
    bool? syncSettingsToGit,
    String? settingsSyncMode,
  }) {
    final profilesMap = <String, dynamic>{};
    for (final p in profiles) {
      profilesMap[p.id] = p.toJson();
    }
    final data = <String, dynamic>{
      'profiles': profilesMap,
      'activeProfileId': activeProfileId,
    };
    if (activeProfile != null) {
      data['autoSync'] = activeProfile.autoSyncEnabled;
      data['syncInterval'] = activeProfile.syncIntervalMinutes;
      data['syncProfile'] = activeProfile.syncProfile;
      data['syncOnStartup'] = activeProfile.syncOnStart;
      data['syncOnStart'] = activeProfile.syncOnStart;
    }
    if (syncSettingsToGit != null) data['syncSettingsToGit'] = syncSettingsToGit;
    if (settingsSyncMode != null) data['settingsSyncMode'] = settingsSyncMode;
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Writes the export JSON to a temporary file and opens the system share
  /// sheet so the user can save or send it.
  ///
  /// When [password] is provided the JSON is encrypted using the
  /// extension-compatible format and saved as `.enc`.
  Future<void> exportAndShare(
    List<Profile> profiles,
    String activeProfileId, {
    String? password,
  }) async {
    final jsonString = buildExportJson(profiles, activeProfileId);

    final now = DateTime.now();
    final datePart =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final String content;
    final String ext;
    if (password != null && password.isNotEmpty) {
      content = await SettingsCrypto.encryptWithPassword(jsonString, password);
      ext = 'enc';
    } else {
      content = jsonString;
      ext = 'json';
    }
    final fileName = 'gitsyncmarks-settings-$datePart.$ext';

    if (kIsWeb) {
      final webBytes = Uint8List.fromList(utf8.encode(content));
      await downloadBytesForWeb(webBytes, fileName, 'application/octet-stream');
      return;
    }

    late final Directory dir;
    try {
      dir = await getTemporaryDirectory();
    } catch (e) {
      rethrow;
    }
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(content);

    late final bool isDesktop;
    try {
      isDesktop = Platform.isLinux || Platform.isWindows || Platform.isMacOS;
    } catch (e) {
      rethrow;
    }
    if (isDesktop) {
      final savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Settings',
        fileName: fileName,
      );
      if (savePath == null) return;
      await file.copy(savePath);
    } else {
      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'GitSyncMarks Settings',
      );
    }
  }

  /// Returns `true` if [content] looks like an encrypted settings file.
  static bool isEncrypted(String content) =>
      content.trimLeft().startsWith('gitsyncmarks-enc:v1');
}
