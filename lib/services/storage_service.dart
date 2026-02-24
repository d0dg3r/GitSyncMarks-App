import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

import '../config/github_credentials.dart';
import '../models/profile.dart';

const _profilesKey = 'profiles_json';
const _activeProfileIdKey = 'active_profile_id';
const _settingsSyncPasswordKey = 'settings_sync_password';
const _syncSettingsToGitKey = 'sync_settings_to_git';
const _settingsSyncModeKey = 'settings_sync_mode';
const _deviceIdKey = 'device_id';

// Legacy single-credential keys (for migration).
const _legacyTokenKey = 'github_token';
const _legacyOwnerKey = 'github_owner';
const _legacyRepoKey = 'github_repo';
const _legacyBranchKey = 'github_branch';
const _legacyBasePathKey = 'github_base_path';
const _legacySelectedRootFoldersKey = 'selected_root_folders';

/// Persists profiles and credentials using secure storage.
class StorageService {
  StorageService() : _storage = const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  // ---------------------------------------------------------------------------
  // Profile storage
  // ---------------------------------------------------------------------------

  Future<List<Profile>> loadProfiles() async {
    final raw = await _storage.read(key: _profilesKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = json.decode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded.entries
            .map((e) => Profile.fromJson(e.value as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<void> saveProfiles(List<Profile> profiles) async {
    final map = <String, dynamic>{};
    for (final p in profiles) {
      map[p.id] = p.toJson();
    }
    await _storage.write(key: _profilesKey, value: json.encode(map));
  }

  Future<String?> loadActiveProfileId() async {
    return _storage.read(key: _activeProfileIdKey);
  }

  Future<void> saveActiveProfileId(String id) async {
    await _storage.write(key: _activeProfileIdKey, value: id);
  }

  // ---------------------------------------------------------------------------
  // Migration: single-credential → first profile
  // ---------------------------------------------------------------------------

  /// Checks for legacy single-credential keys and migrates them to a
  /// "Default" profile. Returns the migrated profile or null.
  Future<Profile?> migrateLegacyCredentials() async {
    final token = await _storage.read(key: _legacyTokenKey);
    if (token == null || token.isEmpty) return null;

    final owner = await _storage.read(key: _legacyOwnerKey);
    final repo = await _storage.read(key: _legacyRepoKey);
    final branch = await _storage.read(key: _legacyBranchKey);
    final basePath = await _storage.read(key: _legacyBasePathKey);
    final foldersRaw = await _storage.read(key: _legacySelectedRootFoldersKey);

    List<String> folders = [];
    if (foldersRaw != null && foldersRaw.isNotEmpty) {
      try {
        final decoded = json.decode(foldersRaw) as List<dynamic>?;
        if (decoded != null) {
          folders = decoded.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
        }
      } catch (_) {}
    }

    final profile = Profile(
      id: 'default',
      name: 'Default',
      credentials: GithubCredentials(
        token: token.trim(),
        owner: (owner ?? '').trim(),
        repo: (repo ?? '').trim(),
        branch: (branch ?? 'main').trim(),
        basePath: (basePath ?? 'bookmarks').trim(),
      ),
      selectedRootFolders: folders,
    );

    await saveProfiles([profile]);
    await saveActiveProfileId(profile.id);

    // Clean up legacy keys.
    await _storage.delete(key: _legacyTokenKey);
    await _storage.delete(key: _legacyOwnerKey);
    await _storage.delete(key: _legacyRepoKey);
    await _storage.delete(key: _legacyBranchKey);
    await _storage.delete(key: _legacyBasePathKey);
    await _storage.delete(key: _legacySelectedRootFoldersKey);

    return profile;
  }

  // ---------------------------------------------------------------------------
  // Legacy helpers kept for backward compatibility in tests
  // ---------------------------------------------------------------------------

  Future<GithubCredentials?> loadCredentials() async {
    final profiles = await loadProfiles();
    if (profiles.isEmpty) return null;
    final activeId = await loadActiveProfileId();
    final active = profiles.firstWhere(
      (p) => p.id == activeId,
      orElse: () => profiles.first,
    );
    return active.credentials;
  }

  Future<void> saveCredentials(GithubCredentials creds) async {
    final profiles = await loadProfiles();
    final activeId = await loadActiveProfileId();
    if (profiles.isEmpty) {
      final p = Profile(
        id: 'default',
        name: 'Default',
        credentials: creds,
      );
      await saveProfiles([p]);
      await saveActiveProfileId(p.id);
      return;
    }
    final updated = profiles.map((p) {
      if (p.id == activeId) return p.copyWith(credentials: creds);
      return p;
    }).toList();
    await saveProfiles(updated);
  }

  Future<void> clearCredentials() async {
    await _storage.delete(key: _profilesKey);
    await _storage.delete(key: _activeProfileIdKey);
  }

  Future<List<String>> loadSelectedRootFolders() async {
    final profiles = await loadProfiles();
    if (profiles.isEmpty) return [];
    final activeId = await loadActiveProfileId();
    final active = profiles.firstWhere(
      (p) => p.id == activeId,
      orElse: () => profiles.first,
    );
    return active.selectedRootFolders;
  }

  // ---------------------------------------------------------------------------
  // Settings sync password (device-local, never synced)
  // ---------------------------------------------------------------------------

  Future<String?> loadSettingsSyncPassword() async {
    return _storage.read(key: _settingsSyncPasswordKey);
  }

  Future<void> saveSettingsSyncPassword(String password) async {
    await _storage.write(key: _settingsSyncPasswordKey, value: password);
  }

  Future<void> deleteSettingsSyncPassword() async {
    await _storage.delete(key: _settingsSyncPasswordKey);
  }

  Future<bool> hasSettingsSyncPassword() async {
    final p = await _storage.read(key: _settingsSyncPasswordKey);
    return p != null && p.isNotEmpty;
  }

  Future<bool> loadSyncSettingsToGit() async {
    final v = await _storage.read(key: _syncSettingsToGitKey);
    return v == 'true';
  }

  Future<void> saveSyncSettingsToGit(bool value) async {
    await _storage.write(
      key: _syncSettingsToGitKey,
      value: value ? 'true' : 'false',
    );
  }

  Future<String> loadSettingsSyncMode() async {
    final v = await _storage.read(key: _settingsSyncModeKey);
    return (v == 'individual' || v == 'global') ? v! : 'global';
  }

  Future<void> saveSettingsSyncMode(String value) async {
    await _storage.write(
      key: _settingsSyncModeKey,
      value: (value == 'individual' || value == 'global') ? value : 'global',
    );
  }

  /// Returns device ID (UUID). Generates and saves if not present (extension-compatible).
  Future<String> getOrCreateDeviceId() async {
    final existing = await _storage.read(key: _deviceIdKey);
    if (existing != null && existing.isNotEmpty) return existing;
    const uuid = Uuid();
    final id = uuid.v4();
    await _storage.write(key: _deviceIdKey, value: id);
    return id;
  }

  // ---------------------------------------------------------------------------
  // Factory reset
  // ---------------------------------------------------------------------------

  Future<void> resetAll() async {
    await _storage.deleteAll();
  }

  // ---------------------------------------------------------------------------
  // Folder selection
  // ---------------------------------------------------------------------------

  Future<void> saveSelectedRootFolders(List<String> names) async {
    final profiles = await loadProfiles();
    final activeId = await loadActiveProfileId();
    if (profiles.isEmpty) return;
    final updated = profiles.map((p) {
      if (p.id == activeId) return p.copyWith(selectedRootFolders: names);
      return p;
    }).toList();
    await saveProfiles(updated);
  }
}
