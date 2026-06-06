import 'dart:convert';

import '../config/github_credentials.dart';
import '../models/profile.dart';
import 'github_api.dart';
import 'settings_crypto.dart';
import 'settings_import_export.dart';
import 'storage_service.dart';

/// Entry from listRemoteDeviceConfigs (extension-compatible).
class DeviceConfigEntry {
  const DeviceConfigEntry({required this.filename, required this.deviceId});

  final String filename;
  final String deviceId;
}

/// Syncs settings to/from GitHub repo as encrypted settings.enc.
class SettingsSyncService {
  SettingsSyncService();

  final _importExport = SettingsImportExportService();

  static const String _globalFileName = 'settings.enc';
  static const String _profilesDirName = 'profiles';

  /// Pushes current profiles to the repo as encrypted settings.
  /// Global mode is deprecated; writes are always individual-style.
  Future<void> push(
    GithubCredentials creds,
    List<Profile> profiles,
    String activeProfileId,
    String password, {
    String mode = 'individual',
    String? deviceId,
    String? clientName,
    bool? syncSettingsToGit,
    String? settingsSyncMode,
  }) async {
    final fileName = _fileNameForMode(
      'individual',
      deviceId,
      clientName: clientName,
    );
    Profile? activeProfile;
    for (final p in profiles) {
      if (p.id == activeProfileId) {
        activeProfile = p;
        break;
      }
    }
    activeProfile ??= profiles.isNotEmpty ? profiles.first : null;
    final jsonString = _importExport.buildExportJson(
      profiles,
      activeProfileId,
      activeProfile: activeProfile,
      syncSettingsToGit: syncSettingsToGit,
      settingsSyncMode: settingsSyncMode,
    );
    final encrypted =
        await SettingsCrypto.encryptWithPassword(jsonString, password);

    final api = _api(creds);
    try {
      final path = '${creds.basePath}/$fileName';
      String? sha;
      try {
        final meta = await api.getFileMeta(path);
        sha = meta?.sha;
      } catch (_) {}

      await api.createOrUpdateFile(
        path,
        encrypted,
        'Sync settings (GitSyncMarks-App)',
        sha: sha,
      );
    } finally {
      api.close();
    }
  }

  static String _fileNameForMode(
    String mode,
    String? deviceId, {
    String? clientName,
  }) {
    final alias = _slugifyClientName(clientName ?? '');
    if (alias.isNotEmpty) {
      return '$_profilesDirName/$alias/$_globalFileName';
    }
    // Legacy fallback for old app states without client name.
    if (deviceId != null && deviceId.length >= 8) {
      return 'settings-${deviceId.substring(0, 8)}.enc';
    }
    return _globalFileName;
  }

  static String _slugifyClientName(String value) {
    final lowered = value.toLowerCase().trim();
    final slug = lowered
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return slug;
  }

  static bool _looksLikeLegacySettingsFile(String name) {
    return name == _globalFileName ||
        RegExp(r'^settings-[^/]+\.enc$').hasMatch(name);
  }

  /// Pulls settings file from the repo, decrypts and returns profiles.
  Future<ImportResult> pull(
    GithubCredentials creds,
    String password, {
    String mode = 'individual',
    String? clientName,
  }) async {
    final api = _api(creds);
    try {
      final path = await _resolveSettingsPathForPull(
        api,
        creds,
        mode: mode,
        clientName: clientName,
      );
      final encrypted = await api.getFileContent(path);
      final decrypted = await SettingsCrypto.decryptWithPassword(
        encrypted,
        password,
      );
      return _importExport.parseSettingsJson(decrypted);
    } finally {
      api.close();
    }
  }

  /// Lists settings files in the repo:
  /// - profiles/<alias>/settings.enc (preferred)
  /// - settings.enc and settings-*.enc (legacy)
  Future<List<DeviceConfigEntry>> listRemoteDeviceConfigs(
    GithubCredentials creds,
  ) async {
    final api = _api(creds);
    try {
      final results = <DeviceConfigEntry>[];

      final baseEntries = await api.getContents(creds.basePath);
      for (final e in baseEntries) {
        if (e.type == 'file' && _looksLikeLegacySettingsFile(e.name)) {
          final id = e.name == _globalFileName ? 'global' : e.name;
          results.add(DeviceConfigEntry(filename: e.name, deviceId: id));
        }
      }

      final profilesPath = '${creds.basePath}/$_profilesDirName';
      try {
        final profileDirs = await api.getContents(profilesPath);
        for (final dir in profileDirs) {
          if (dir.type != 'dir') continue;
          final candidatePath = '$profilesPath/${dir.name}/$_globalFileName';
          final meta = await api.getFileMeta(candidatePath);
          if (meta != null) {
            results.add(
              DeviceConfigEntry(
                filename: '$_profilesDirName/${dir.name}/$_globalFileName',
                deviceId: dir.name,
              ),
            );
          }
        }
      } on GithubApiException catch (e) {
        if (e.statusCode != 404) rethrow;
      }

      results.sort((a, b) {
        if (a.filename == _globalFileName) return -1;
        if (b.filename == _globalFileName) return 1;
        return a.filename.compareTo(b.filename);
      });
      return results;
    } finally {
      api.close();
    }
  }

  /// Imports a specific settings file, applies settings and profiles.
  Future<ImportResult> importDeviceConfig(
    GithubCredentials creds,
    String filename,
    String password, {
    required StorageService storage,
    required Future<void> Function(ImportResult) applyProfiles,
  }) async {
    final api = _api(creds);
    try {
      final relativePath = _normalizeRelativeSettingsPath(filename);
      final path = '${creds.basePath}/$relativePath';
      final encrypted = await api.getFileContent(path);
      final decrypted = await SettingsCrypto.decryptWithPassword(
        encrypted,
        password,
      );
      final result = _importExport.parseSettingsJson(decrypted);
      final data = json.decode(decrypted) as Map<String, dynamic>;
      if (data['syncSettingsToGit'] != null) {
        await storage.saveSyncSettingsToGit(data['syncSettingsToGit'] == true);
      }
      if (data['settingsSyncMode'] != null) {
        await storage.saveSettingsSyncMode('individual');
      }
      await applyProfiles(result);
      return result;
    } finally {
      api.close();
    }
  }

  /// Checks if any compatible settings file exists in the repo.
  Future<bool> exists(GithubCredentials creds) async {
    final api = _api(creds);
    try {
      final globalPath = '${creds.basePath}/$_globalFileName';
      final global = await api.getFileMeta(globalPath);
      if (global != null) return true;
      final legacy = await _collectLegacyFiles(api, creds);
      return legacy.isNotEmpty;
    } finally {
      api.close();
    }
  }

  String _normalizeRelativeSettingsPath(String filename) {
    var clean = filename.trim();
    if (clean.startsWith('/')) clean = clean.substring(1);
    return clean;
  }

  Future<String> _resolveSettingsPathForPull(
    GithubApi api,
    GithubCredentials creds, {
    required String mode,
    String? clientName,
  }) async {
    final base = creds.basePath;
    final candidates = <String>[];

    final alias = _slugifyClientName(clientName ?? '');
    if (alias.isNotEmpty) {
      candidates.add('$base/$_profilesDirName/$alias/$_globalFileName');
    }
    candidates.add('$base/$_globalFileName');

    final legacy = await _collectLegacyFiles(api, creds);
    candidates.addAll(legacy.map((f) => '$base/$f'));

    for (final path in candidates) {
      final meta = await api.getFileMeta(path);
      if (meta != null) return path;
    }
    throw GithubApiException('No settings file found in repository');
  }

  GithubApi _api(GithubCredentials creds) => GithubApi(
        token: creds.token,
        owner: creds.owner,
        repo: creds.repo,
        branch: creds.branch,
        basePath: creds.basePath,
        gitProvider: creds.gitProvider,
        serverUrl: creds.serverUrl,
      );

  Future<List<String>> _collectLegacyFiles(
    GithubApi api,
    GithubCredentials creds,
  ) async {
    final entries = await api.getContents(creds.basePath);
    final out = <String>[];
    for (final e in entries) {
      if (e.type == 'file' && _looksLikeLegacySettingsFile(e.name)) {
        out.add(e.name);
      }
    }
    return out;
  }
}
