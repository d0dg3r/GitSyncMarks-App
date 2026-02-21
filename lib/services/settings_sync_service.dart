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

  /// Pushes current profiles to the repo as encrypted settings.
  /// [mode] 'global' → settings.enc, 'individual' → settings-{deviceId8}.enc
  Future<void> push(
    GithubCredentials creds,
    List<Profile> profiles,
    String activeProfileId,
    String password, {
    String mode = 'global',
    String? deviceId,
    bool? syncSettingsToGit,
    String? settingsSyncMode,
  }) async {
    final fileName = _fileNameForMode(mode, deviceId);
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
    final encrypted = await SettingsCrypto.encryptWithPassword(jsonString, password);

    final api = GithubApi(
      token: creds.token,
      owner: creds.owner,
      repo: creds.repo,
      branch: creds.branch,
      basePath: creds.basePath,
    );
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
        'Sync settings (GitSyncMarks-Mobile)',
        sha: sha,
      );
    } finally {
      api.close();
    }
  }

  static String _fileNameForMode(String mode, String? deviceId) {
    if (mode == 'individual' && deviceId != null && deviceId.length >= 8) {
      return 'settings-${deviceId.substring(0, 8)}.enc';
    }
    return _globalFileName;
  }

  /// Pulls settings.enc from the repo, decrypts and returns profiles.
  Future<ImportResult> pull(
    GithubCredentials creds,
    String password,
  ) async {
    final api = GithubApi(
      token: creds.token,
      owner: creds.owner,
      repo: creds.repo,
      branch: creds.branch,
      basePath: creds.basePath,
    );
    try {
      final path = '${creds.basePath}/$_globalFileName';
      final encrypted = await api.getFileContent(path);
      final decrypted = await SettingsCrypto.decryptWithPassword(encrypted, password);
      return _importExport.parseSettingsJson(decrypted);
    } finally {
      api.close();
    }
  }

  /// Lists settings.enc and settings-*.enc files in the repo (extension-compatible).
  Future<List<DeviceConfigEntry>> listRemoteDeviceConfigs(
    GithubCredentials creds,
  ) async {
    final api = GithubApi(
      token: creds.token,
      owner: creds.owner,
      repo: creds.repo,
      branch: creds.branch,
      basePath: creds.basePath,
    );
    try {
      final entries = await api.getContents(creds.basePath);
      final results = <DeviceConfigEntry>[];
      final individualRe = RegExp(r'^settings-([a-f0-9]{8})\.enc$');
      for (final e in entries) {
        if (e.type != 'file') continue;
        final name = e.name;
        if (name == _globalFileName) {
          results.insert(0, DeviceConfigEntry(filename: name, deviceId: 'global'));
        } else {
          final m = individualRe.firstMatch(name);
          if (m != null) {
            results.add(DeviceConfigEntry(filename: name, deviceId: m.group(1)!));
          }
        }
      }
      return results;
    } finally {
      api.close();
    }
  }

  /// Imports a specific device config file, applies settings and profiles.
  Future<ImportResult> importDeviceConfig(
    GithubCredentials creds,
    String filename,
    String password, {
    required StorageService storage,
    required Future<void> Function(ImportResult) applyProfiles,
  }) async {
    final api = GithubApi(
      token: creds.token,
      owner: creds.owner,
      repo: creds.repo,
      branch: creds.branch,
      basePath: creds.basePath,
    );
    try {
      final path = '${creds.basePath}/$filename';
      final encrypted = await api.getFileContent(path);
      final decrypted = await SettingsCrypto.decryptWithPassword(encrypted, password);
      final result = _importExport.parseSettingsJson(decrypted);
      final data = json.decode(decrypted) as Map<String, dynamic>;
      if (data['syncSettingsToGit'] != null) {
        await storage.saveSyncSettingsToGit(data['syncSettingsToGit'] == true);
      }
      if (data['settingsSyncMode'] != null) {
        final mode = data['settingsSyncMode'] as String?;
        if (mode == 'global' || mode == 'individual') {
          await storage.saveSettingsSyncMode(mode!);
        }
      }
      await applyProfiles(result);
      return result;
    } finally {
      api.close();
    }
  }

  /// Checks if settings.enc exists in the repo.
  Future<bool> exists(GithubCredentials creds) async {
    final api = GithubApi(
      token: creds.token,
      owner: creds.owner,
      repo: creds.repo,
      branch: creds.branch,
      basePath: creds.basePath,
    );
    try {
      final path = '${creds.basePath}/$_globalFileName';
      final meta = await api.getFileMeta(path);
      return meta != null;
    } finally {
      api.close();
    }
  }
}
