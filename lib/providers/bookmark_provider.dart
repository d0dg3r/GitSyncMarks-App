import 'dart:async';

import 'package:flutter/foundation.dart';

import '../config/github_credentials.dart';
import '../models/bookmark_node.dart';
import '../models/profile.dart';
import '../repositories/bookmark_repository.dart';
import '../services/bookmark_cache.dart';
import '../services/git_data_api.dart';
import '../services/github_api.dart';
import '../services/settings_sync_service.dart';
import '../services/storage_service.dart';
import '../services/github_repos_service.dart';
import '../services/linkwarden_api.dart';
import '../services/linkwarden_sync.dart';
import '../services/sync_engine.dart';
import '../services/sync_history.dart';
import '../services/sync_state.dart';
import '../utils/bookmark_filename.dart';

/// App state: profiles, credentials, bookmarks, sync status.
class BookmarkProvider extends ChangeNotifier {
  BookmarkProvider({
    StorageService? storage,
    BookmarkRepository? repository,
    BookmarkCacheService? cacheService,
    SyncStateService? syncStateService,
  })  : _storage = storage ?? StorageService(),
        _repository = repository ?? BookmarkRepository(),
        _cache = cacheService ?? BookmarkCacheService(),
        _syncState = syncStateService ?? SyncStateService();

  final StorageService _storage;
  final BookmarkRepository _repository;
  final BookmarkCacheService _cache;
  final SyncStateService _syncState;
  final SettingsSyncService _settingsSync = SettingsSyncService();

  List<Profile> _profiles = [];
  String? _activeProfileId;

  GithubCredentials? _credentials;
  List<BookmarkFolder> _rootFolders = [];
  List<String> _discoveredRootFolderNames = [];
  List<String> _selectedRootFolders = [];
  String? _viewRootFolder;
  bool _isLoading = false;
  String? _error;
  String? _lastSuccessMessage;
  DateTime? _lastSyncTime;
  String? _lastSyncCommitSha;
  Timer? _autoSyncTimer;
  DateTime? _nextAutoSyncAt;
  String _searchQuery = '';
  bool _hasConflict = false;
  List<GitHubRepo> _githubRepos = [];
  bool _githubReposLoading = false;
  String? _githubReposUsername;
  BookmarkFolder? _linkwardenFolder;
  bool _linkwardenLoading = false;

  late final SyncEngine _syncEngine = SyncEngine(syncState: _syncState);
  late final SyncHistoryService _historyService =
      SyncHistoryService(syncState: _syncState);

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  List<Profile> get profiles => List.unmodifiable(_profiles);
  String? get activeProfileId => _activeProfileId;

  Profile? get activeProfile {
    if (_profiles.isEmpty) return null;
    return _profiles.cast<Profile?>().firstWhere(
          (p) => p!.id == _activeProfileId,
          orElse: () => _profiles.first,
        );
  }

  GithubCredentials? get credentials => _credentials;

  List<BookmarkFolder> get rootFolders => _rootFolders;

  String? get viewRootFolder => _viewRootFolder;

  /// The root folders currently in effect, considering [viewRootFolder].
  /// When a view root is set, its subfolder children become the effective
  /// roots and any loose bookmarks are wrapped in an extra tab.
  List<BookmarkFolder> get _effectiveRootFolders {
    if (_viewRootFolder == null || _viewRootFolder!.isEmpty) {
      return _rootFolders;
    }
    final target = _findFolderByPath(_rootFolders, _viewRootFolder!);
    if (target == null) return _rootFolders;

    final subfolders = target.children.whereType<BookmarkFolder>().toList();
    final looseBookmarks = target.children.whereType<Bookmark>().toList();

    if (subfolders.isEmpty) {
      return [target];
    }
    if (looseBookmarks.isNotEmpty) {
      return [
        BookmarkFolder(
          title: target.title,
          children: looseBookmarks,
          dirName: target.dirName,
        ),
        ...subfolders,
      ];
    }
    return subfolders;
  }

  List<BookmarkFolder> get displayedRootFolders {
    final effective = _effectiveRootFolders;
    List<BookmarkFolder> base;
    if (_selectedRootFolders.isEmpty) {
      base = effective;
    } else {
      final names = _selectedRootFolders.toSet();
      final filtered =
          effective.where((f) => names.contains(f.title)).toList();
      base = filtered.isEmpty ? effective : filtered;
    }
    final extras = <BookmarkFolder>[];
    final reposFolder = githubReposFolder;
    if (reposFolder != null) extras.add(reposFolder);
    if (_linkwardenFolder != null) extras.add(_linkwardenFolder!);
    if (extras.isEmpty) return base;
    return [...base, ...extras];
  }

  List<String> get availableRootFolderNames => _effectiveRootFolders.isNotEmpty
      ? _effectiveRootFolders.map((f) => f.title).toList()
      : _discoveredRootFolderNames;

  /// Full folder tree (ignoring viewRootFolder) for the settings picker.
  List<BookmarkFolder> get fullRootFolders => _rootFolders;

  List<String> get selectedRootFolders =>
      List.unmodifiable(_selectedRootFolders);

  bool get isLoading => _isLoading;

  String? get error => _error;

  String? get lastSuccessMessage => _lastSuccessMessage;

  bool get hasCredentials => _credentials?.isValid ?? false;

  bool get hasBookmarks => _rootFolders.isNotEmpty;

  bool get canAddProfile => _profiles.length < maxProfiles;

  bool get hasConflict => _hasConflict;

  List<GitHubRepo> get githubRepos => _githubRepos;
  bool get githubReposLoading => _githubReposLoading;
  String? get githubReposUsername => _githubReposUsername;

  BookmarkFolder? get linkwardenFolder => _linkwardenFolder;
  bool get linkwardenLoading => _linkwardenLoading;
  DateTime? get lastSyncTime => _lastSyncTime;
  String? get lastSyncCommitSha => _lastSyncCommitSha;
  String? get lastSyncCommitShort {
    final sha = _lastSyncCommitSha?.trim();
    if (sha == null || sha.isEmpty) return null;
    return sha.length > 7 ? sha.substring(0, 7) : sha;
  }

  int get bookmarkCount => _countBookmarks(_rootFolders);

  String get searchQuery => _searchQuery;

  DateTime? get nextAutoSyncAt => _nextAutoSyncAt;

  /// Display root folders filtered by search query.
  List<BookmarkFolder> get filteredDisplayedRootFolders {
    final displayed = displayedRootFolders;
    if (_searchQuery.trim().isEmpty) return displayed;
    final q = _searchQuery.trim().toLowerCase();
    return displayed
        .map((f) => _filterFolder(f, q))
        .whereType<BookmarkFolder>()
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Load / init
  // ---------------------------------------------------------------------------

  /// Loads saved profiles, migrates legacy credentials if needed, and loads
  /// cached bookmarks for the active profile.
  Future<void> loadCredentials() async {
    try {
      _profiles = await _storage.loadProfiles();

      if (_profiles.isEmpty) {
        final migrated = await _storage.migrateLegacyCredentials();
        if (migrated != null) {
          _profiles = [migrated];
        }
      }

      if (_profiles.isEmpty) {
        final defaultProfile = Profile(
          id: 'default',
          name: 'Default',
          credentials: GithubCredentials(
            token: '',
            owner: '',
            repo: '',
            branch: 'main',
            basePath: 'bookmarks',
          ),
        );
        _profiles = [defaultProfile];
        _activeProfileId = 'default';
        await _storage.saveProfiles(_profiles);
        await _storage.saveActiveProfileId('default');
      }

      _activeProfileId = await _storage.loadActiveProfileId();

      final active = activeProfile;
      if (active != null) {
        _credentials = active.credentials;
        _selectedRootFolders = active.selectedRootFolders;
        _viewRootFolder = active.viewRootFolder;
      } else {
        _credentials = null;
        _selectedRootFolders = [];
        _viewRootFolder = null;
      }

      _error = null;
      if (_credentials != null && _credentials!.isValid) {
        await loadFromCache();
        final active = activeProfile;
        if (active != null && active.syncOnStart) {
          await syncBookmarks();
        }
        _startOrStopAutoSync();
        if (active?.githubReposEnabled == true) {
          loadGitHubRepos();
        }
        if (active?.linkwardenEnabled == true &&
            active?.linkwardenUrl != null &&
            active?.linkwardenToken != null) {
          loadLinkwarden(
            url: active!.linkwardenUrl!,
            token: active.linkwardenToken!,
          );
        }
      } else {
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Loads bookmarks from local cache for current credentials.
  Future<void> loadFromCache() async {
    final c = _credentials;
    if (c == null || !c.isValid) {
      notifyListeners();
      return;
    }
    final cached = await _cache.loadCache(c.cacheKey);
    if (cached != null && cached.isNotEmpty) {
      _rootFolders = cached;
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Profile CRUD
  // ---------------------------------------------------------------------------

  Future<Profile> addProfile(String name) async {
    final id = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final profile = Profile(
      id: id,
      name: name,
      credentials: GithubCredentials(
        token: '',
        owner: '',
        repo: '',
        branch: 'main',
        basePath: 'bookmarks',
      ),
    );
    _profiles = [..._profiles, profile];
    await _storage.saveProfiles(_profiles);
    await switchProfile(id);
    return profile;
  }

  Future<void> renameProfile(String id, String newName) async {
    _profiles = _profiles.map((p) {
      if (p.id == id) return p.copyWith(name: newName);
      return p;
    }).toList();
    await _storage.saveProfiles(_profiles);
    notifyListeners();
  }

  Future<void> deleteProfile(String id) async {
    if (_profiles.length <= 1) return;
    _profiles = _profiles.where((p) => p.id != id).toList();
    await _storage.saveProfiles(_profiles);

    if (_activeProfileId == id) {
      await switchProfile(_profiles.first.id);
    } else {
      notifyListeners();
    }
  }

  Future<void> switchProfile(String id) async {
    _saveCurrentProfileLocally();

    _activeProfileId = id;
    await _storage.saveActiveProfileId(id);

    final active = activeProfile;
    if (active != null) {
      _credentials = active.credentials;
      _selectedRootFolders = active.selectedRootFolders;
      _viewRootFolder = active.viewRootFolder;
    } else {
      _credentials = null;
      _selectedRootFolders = [];
      _viewRootFolder = null;
    }

    _rootFolders = [];
    _discoveredRootFolderNames = [];
    _error = null;
    _lastSuccessMessage = null;
    _lastSyncTime = null;

    if (_credentials != null && _credentials!.isValid) {
      await loadFromCache();
      _startOrStopAutoSync();
    } else {
      _stopAutoSync();
      notifyListeners();
    }
  }

  /// Replaces all profiles (used by import).
  Future<void> replaceProfiles(
    List<Profile> profiles, {
    required String activeId,
    bool triggerSync = true,
  }) async {
    _profiles = profiles;
    await _storage.saveProfiles(_profiles);
    // Prevent _saveCurrentProfileLocally() in switchProfile() from overwriting
    // freshly imported profiles with stale in-memory credentials.
    _activeProfileId = null;
    _credentials = null;
    await switchProfile(activeId);
    if (triggerSync && _credentials != null && _credentials!.isValid) {
      await syncBookmarks();
    }
  }

  /// Persists current form state back into the in-memory profile list
  /// so switching profiles doesn't lose unsaved edits.
  void _saveCurrentProfileLocally() {
    if (_activeProfileId == null || _credentials == null) return;
    _profiles = _profiles.map((p) {
      if (p.id == _activeProfileId) {
        return p.copyWith(
          credentials: _credentials,
          selectedRootFolders: _selectedRootFolders,
        );
      }
      return p;
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // Selected root folders
  // ---------------------------------------------------------------------------

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> updateSyncSettings({
    bool? autoSyncEnabled,
    String? syncProfile,
    int? customIntervalMinutes,
    bool? syncOnStart,
    bool? allowMoveReorder,
    bool? githubReposEnabled,
    String? linkwardenUrl,
    String? linkwardenToken,
    bool? linkwardenEnabled,
  }) async {
    final active = activeProfile;
    if (active == null) return;
    _profiles = _profiles.map((p) {
      if (p.id == _activeProfileId) {
        return p.copyWith(
          autoSyncEnabled: autoSyncEnabled ?? p.autoSyncEnabled,
          syncProfile: syncProfile ?? p.syncProfile,
          customIntervalMinutes:
              customIntervalMinutes ?? p.customIntervalMinutes,
          syncOnStart: syncOnStart ?? p.syncOnStart,
          allowMoveReorder: allowMoveReorder ?? p.allowMoveReorder,
          githubReposEnabled: githubReposEnabled ?? p.githubReposEnabled,
          linkwardenUrl: linkwardenUrl ?? p.linkwardenUrl,
          linkwardenToken: linkwardenToken ?? p.linkwardenToken,
          linkwardenEnabled: linkwardenEnabled ?? p.linkwardenEnabled,
        );
      }
      return p;
    }).toList();
    await _storage.saveProfiles(_profiles);
    _startOrStopAutoSync();
    notifyListeners();
  }

  Future<void> setViewRootFolder(String? path, {bool save = false}) async {
    _viewRootFolder = (path != null && path.isEmpty) ? null : path;
    _selectedRootFolders = [];
    if (save) {
      _profiles = _profiles.map((p) {
        if (p.id == _activeProfileId) {
          return p.copyWith(
            viewRootFolder: _viewRootFolder,
            clearViewRootFolder: _viewRootFolder == null,
            selectedRootFolders: const [],
          );
        }
        return p;
      }).toList();
      await _storage.saveProfiles(_profiles);
    }
    notifyListeners();
  }

  Future<void> setSelectedRootFolders(List<String> names,
      {bool save = false}) async {
    _selectedRootFolders = names.toList();
    if (save) {
      _updateActiveProfileFolders(names);
      await _storage.saveProfiles(_profiles);
    }
    notifyListeners();
  }

  void _updateActiveProfileFolders(List<String> names) {
    _profiles = _profiles.map((p) {
      if (p.id == _activeProfileId) {
        return p.copyWith(selectedRootFolders: names);
      }
      return p;
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // Credentials update (from Settings form)
  // ---------------------------------------------------------------------------

  Future<void> updateCredentials(GithubCredentials creds,
      {bool save = false}) async {
    _credentials = creds;
    if (save) {
      if (_profiles.isEmpty) {
        final p = Profile(id: 'default', name: 'Default', credentials: creds);
        _profiles = [p];
        _activeProfileId = 'default';
      } else {
        _profiles = _profiles.map((p) {
          if (p.id == _activeProfileId) return p.copyWith(credentials: creds);
          return p;
        }).toList();
      }
      await _storage.saveProfiles(_profiles);
    }
    _error = null;
    notifyListeners();
  }

  Future<void> saveCredentials() async {
    if (_credentials != null) {
      _profiles = _profiles.map((p) {
        if (p.id == _activeProfileId) {
          return p.copyWith(credentials: _credentials);
        }
        return p;
      }).toList();
      await _storage.saveProfiles(_profiles);
      _lastSuccessMessage = 'Settings saved';
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Test connection / sync
  // ---------------------------------------------------------------------------

  Future<bool> testConnection(GithubCredentials creds) async {
    _isLoading = true;
    _error = null;
    _lastSuccessMessage = null;
    notifyListeners();

    try {
      _discoveredRootFolderNames = await _repository.testConnection(creds);
      _lastSuccessMessage = 'Connection successful';
      notifyListeners();
      return true;
    } on GithubApiException catch (e) {
      _discoveredRootFolderNames = [];
      _error = e.statusCode != null
          ? 'Error ${e.statusCode}: ${e.message}'
          : e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _discoveredRootFolderNames = [];
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adds a bookmark to the given folder via GitHub API.
  /// [folderPath] is e.g. "bookmarks/toolbar".
  /// Adds a bookmark to a folder using the folder object. Persists to GitHub.
  Future<bool> addBookmark(
    String title,
    String url,
    BookmarkFolder targetFolder,
  ) async {
    final folderPath = getFolderPath(targetFolder);
    if (folderPath == null) {
      _error = 'Could not determine folder path';
      notifyListeners();
      return false;
    }
    return addBookmarkFromUrl(url, title, folderPath);
  }

  Future<bool> addBookmarkFromUrl(
    String url,
    String title,
    String folderPath,
  ) async {
    final c = _credentials;
    if (c == null || !c.isValid) {
      _error = 'Configure GitHub connection in Settings';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    _lastSuccessMessage = null;
    notifyListeners();

    try {
      final ok =
          await _repository.addBookmarkToFolder(c, folderPath, title, url);
      if (ok) {
        _lastSuccessMessage = 'Bookmark added';
        await syncBookmarks();
        return true;
      }
      return false;
    } on GithubApiException catch (e) {
      _error = e.statusCode != null
          ? 'Error ${e.statusCode}: ${e.message}'
          : e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> syncBookmarks([GithubCredentials? creds]) async {
    final c = creds ?? _credentials;
    if (c == null || !c.isValid) {
      _error = 'Configure GitHub connection in Settings';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    _lastSuccessMessage = null;
    notifyListeners();

    try {
      final profileId = _activeProfileId ?? '';
      final baseFiles = _syncState.getLastSyncFiles(profileId);
      final prevCommitSha = _syncState.getLastCommitSha(profileId);

      final result = await _repository.fetchBookmarks(
        c,
        baseFiles: baseFiles.isNotEmpty ? baseFiles : null,
      );
      _rootFolders = result.rootFolders;
      await _cache.saveCache(c.cacheKey, _rootFolders);
      _lastSyncTime = DateTime.now();
      _lastSyncCommitSha = result.commitSha;

      if (result.commitSha != null) {
        await _syncState.saveSyncState(
          profileId: profileId,
          commitSha: result.commitSha!,
          shaMap: result.shaMap,
          fileMap: result.fileMap,
          previousCommitSha: prevCommitSha,
        );
      }

      final bc = _countBookmarks(_rootFolders);
      _lastSuccessMessage =
          'Synced ${_rootFolders.length} folder(s), $bc bookmark(s)';

      final syncSettingsToGit = await _storage.loadSyncSettingsToGit();
      if (syncSettingsToGit) {
        final password = await _storage.loadSettingsSyncPassword();
        if (password != null && password.isNotEmpty) {
          await _storage.loadSettingsSyncMode();
          final deviceId = await _storage.getOrCreateDeviceId();
          final clientName = await _storage.loadSettingsSyncClientName();
          try {
            // Legacy-compatible read: pull resolves individual first and can
            // still read old global/legacy files as fallback.
            final result = await _settingsSync.pull(
              c,
              password,
              mode: 'individual',
              clientName: clientName,
            );
            if (result.syncSettingsToGit != null) {
              await _storage.saveSyncSettingsToGit(result.syncSettingsToGit!);
            }
            if (result.settingsSyncMode != null) {
              await _storage.saveSettingsSyncMode(result.settingsSyncMode!);
            }
            await replaceProfiles(result.profiles,
                activeId: result.activeProfileId, triggerSync: false);
          } catch (_) {
            // settings file may not exist yet; ignore
          }
          if (_profiles.isNotEmpty) {
            try {
              final activeId = _activeProfileId ?? _profiles.first.id;
              await _settingsSync.push(
                c,
                _profiles,
                activeId,
                password,
                mode: 'individual',
                deviceId: deviceId,
                clientName: clientName,
                syncSettingsToGit: syncSettingsToGit,
                settingsSyncMode: 'individual',
              );
            } catch (_) {
              // Push failure does not fail bookmark sync
            }
          }
        }
      }

      _scheduleNextAutoSync();
      notifyListeners();
      return true;
    } on GithubApiException catch (e) {
      _error = e.statusCode != null
          ? 'Error ${e.statusCode}: ${e.message}'
          : e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Force push / pull (conflict resolution)
  // ---------------------------------------------------------------------------

  /// Force pull: overwrite local bookmarks with remote state.
  Future<bool> forcePull() async {
    final c = _credentials;
    if (c == null || !c.isValid) {
      _error = 'Configure GitHub connection in Settings';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    _lastSuccessMessage = null;
    notifyListeners();

    try {
      final profileId = _activeProfileId ?? '';
      final result = await _syncEngine.forcePull(
        creds: c,
        profileId: profileId,
      );

      if (!result.success) {
        _error = result.message;
        notifyListeners();
        return false;
      }

      _rootFolders = result.rootFolders ?? [];
      await _cache.saveCache(c.cacheKey, _rootFolders);
      _lastSyncTime = DateTime.now();
      _lastSyncCommitSha = result.commitSha;
      _hasConflict = false;
      _lastSuccessMessage = result.message;
      _scheduleNextAutoSync();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Force push: overwrite remote with current local bookmarks.
  Future<bool> forcePush() async {
    final c = _credentials;
    if (c == null || !c.isValid) {
      _error = 'Configure GitHub connection in Settings';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    _lastSuccessMessage = null;
    notifyListeners();

    try {
      final profileId = _activeProfileId ?? '';
      final deviceId = await _storage.getOrCreateDeviceId();
      final result = await _syncEngine.forcePush(
        creds: c,
        profileId: profileId,
        cachedTree: _rootFolders,
        deviceId: deviceId,
      );

      if (!result.success) {
        _error = result.message;
        notifyListeners();
        return false;
      }

      _lastSyncTime = DateTime.now();
      _lastSyncCommitSha = result.commitSha;
      _hasConflict = false;
      _lastSuccessMessage = result.message;
      _scheduleNextAutoSync();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clears the conflict flag (e.g. after user acknowledges it).
  void clearConflict() {
    _hasConflict = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Sync History
  // ---------------------------------------------------------------------------

  /// Lists recent commits that touched the bookmark path.
  Future<List<CommitEntry>> listSyncHistory({int perPage = 20}) async {
    final c = _credentials;
    if (c == null || !c.isValid) return [];
    return _historyService.listHistory(c, perPage: perPage);
  }

  /// Previews the diff between a target commit and current bookmarks.
  Future<DiffPreviewResult> previewCommitDiff(String commitSha) async {
    final c = _credentials;
    if (c == null || !c.isValid) {
      return DiffPreviewResult(success: false, message: 'Not configured');
    }
    return _historyService.previewCommitDiff(c, commitSha, _rootFolders);
  }

  /// Restores bookmarks from a specific commit SHA.
  Future<bool> restoreFromCommit(String commitSha) async {
    final c = _credentials;
    if (c == null || !c.isValid) {
      _error = 'Configure GitHub connection in Settings';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    _lastSuccessMessage = null;
    notifyListeners();

    try {
      final profileId = _activeProfileId ?? '';
      final deviceId = await _storage.getOrCreateDeviceId();
      final result = await _historyService.restoreFromCommit(
        c,
        commitSha,
        profileId,
        deviceId: deviceId,
      );

      if (!result.success) {
        _error = result.message;
        notifyListeners();
        return false;
      }

      _rootFolders = result.rootFolders ?? [];
      await _cache.saveCache(c.cacheKey, _rootFolders);
      _lastSyncTime = DateTime.now();
      _lastSyncCommitSha = result.commitSha;
      _hasConflict = false;
      _lastSuccessMessage = result.message;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Undoes the last sync by restoring from the previous commit.
  Future<bool> undoLastSync() async {
    final c = _credentials;
    if (c == null || !c.isValid) {
      _error = 'Configure GitHub connection in Settings';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    _lastSuccessMessage = null;
    notifyListeners();

    try {
      final profileId = _activeProfileId ?? '';
      final deviceId = await _storage.getOrCreateDeviceId();
      final result = await _historyService.undoLastSync(
        c,
        profileId,
        deviceId: deviceId,
      );

      if (!result.success) {
        _error = result.message;
        notifyListeners();
        return false;
      }

      _rootFolders = result.rootFolders ?? [];
      await _cache.saveCache(c.cacheKey, _rootFolders);
      _lastSyncTime = DateTime.now();
      _lastSyncCommitSha = result.commitSha;
      _hasConflict = false;
      _lastSuccessMessage = result.message;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Whether undo is available (previous commit SHA exists).
  bool get canUndoLastSync {
    final profileId = _activeProfileId ?? '';
    final prev = _syncState.getPreviousCommitSha(profileId);
    return prev != null && prev.isNotEmpty;
  }

  // ---------------------------------------------------------------------------
  // GitHub Repos virtual folder
  // ---------------------------------------------------------------------------

  Future<void> loadGitHubRepos() async {
    final c = _credentials;
    if (c == null || !c.isValid) return;

    _githubReposLoading = true;
    notifyListeners();

    try {
      final svc = GitHubReposService(token: c.token);
      if (_githubReposUsername == null || _githubReposUsername!.isEmpty) {
        _githubReposUsername = await svc.fetchCurrentUser();
      }
      _githubRepos = await svc.fetchUserRepos();
    } catch (e) {
      debugPrint('GitHub repos error: $e');
    } finally {
      _githubReposLoading = false;
      notifyListeners();
    }
  }

  BookmarkFolder? get githubReposFolder {
    if (_githubRepos.isEmpty) return null;
    final name = _githubReposUsername ?? 'user';
    return BookmarkFolder(
      title: 'GitHubRepos ($name)',
      children: _githubRepos.map((r) {
        final title = r.isPrivate ? '${r.fullName} (private)' : r.fullName;
        return Bookmark(title: title, url: r.htmlUrl);
      }).toList(),
      dirName: '_github_repos',
    );
  }

  // ---------------------------------------------------------------------------
  // Linkwarden integration
  // ---------------------------------------------------------------------------

  Future<void> loadLinkwarden({
    required String url,
    required String token,
  }) async {
    _linkwardenLoading = true;
    notifyListeners();

    try {
      final api = LinkwardenAPI(baseUrl: url, token: token);
      final result = await fetchLinkwardenAsFolder(api);
      _linkwardenFolder = result.folder;
    } catch (e) {
      debugPrint('Linkwarden error: $e');
    } finally {
      _linkwardenLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveToLinkwarden({
    required String url,
    required String token,
    required String linkUrl,
    required String linkName,
    int? collectionId,
    List<String>? tags,
  }) async {
    try {
      final api = LinkwardenAPI(baseUrl: url, token: token);
      await api.saveLink(
        url: linkUrl,
        name: linkName,
        collectionId: collectionId,
        tags: tags,
      );
      return true;
    } catch (e) {
      debugPrint('Linkwarden save error: $e');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Misc
  // ---------------------------------------------------------------------------

  /// Resets all data (profiles, credentials, cache) to factory state.
  Future<void> resetAll() async {
    _stopAutoSync();
    await _storage.resetAll();
    await _cache.clearCache();
    await _syncState.clearAll();
    _profiles = [];
    _activeProfileId = null;
    _credentials = null;
    _rootFolders = [];
    _discoveredRootFolderNames = [];
    _selectedRootFolders = [];
    _viewRootFolder = null;
    _error = null;
    _lastSuccessMessage = null;
    _searchQuery = '';
    _lastSyncTime = null;
    _lastSyncCommitSha = null;
    _nextAutoSyncAt = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSuccessMessage() {
    _lastSuccessMessage = null;
    notifyListeners();
  }

  /// Clears the bookmark cache and optionally syncs fresh data.
  Future<bool> clearCacheAndSync() async {
    await _cache.clearCache();
    _rootFolders = [];
    _lastSyncTime = null;
    _lastSyncCommitSha = null;
    _error = null;
    _lastSuccessMessage = null;
    notifyListeners();
    if (_credentials != null && _credentials!.isValid) {
      return await syncBookmarks();
    }
    return true;
  }

  /// Seeds the provider with test data for screenshot generation.
  @visibleForTesting
  void seedWith(
    List<BookmarkFolder> folders, {
    GithubCredentials? credentials,
  }) {
    _rootFolders = folders;
    _credentials = credentials ??
        GithubCredentials(
          token: 'test-token',
          owner: 'user',
          repo: 'bookmarks',
          branch: 'main',
        );
    _selectedRootFolders = folders.map((f) => f.title).toList();
    _error = null;
    _isLoading = false;

    if (_profiles.isEmpty) {
      _profiles = [
        Profile(
          id: 'default',
          name: 'Default',
          credentials: _credentials!,
          selectedRootFolders: _selectedRootFolders,
        ),
      ];
      _activeProfileId = 'default';
    }

    notifyListeners();
  }

  void _stopAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
    _nextAutoSyncAt = null;
  }

  void _startOrStopAutoSync() {
    _stopAutoSync();
    final active = activeProfile;
    if (active == null || !active.autoSyncEnabled || !hasCredentials) return;
    final intervalMinutes = active.syncIntervalMinutes;
    _nextAutoSyncAt = DateTime.now().add(Duration(minutes: intervalMinutes));
    _autoSyncTimer = Timer.periodic(
      Duration(minutes: intervalMinutes),
      (_) async {
        if (_credentials != null && _credentials!.isValid) {
          await syncBookmarks();
        }
      },
    );
    notifyListeners();
  }

  void _scheduleNextAutoSync() {
    final active = activeProfile;
    if (active == null || !active.autoSyncEnabled) return;
    final intervalMinutes = active.syncIntervalMinutes;
    _nextAutoSyncAt = DateTime.now().add(Duration(minutes: intervalMinutes));
    notifyListeners();
  }

  /// Recursively filter folder by search query. Returns null if no match.
  BookmarkFolder? _filterFolder(BookmarkFolder folder, String query) {
    final filteredChildren = <BookmarkNode>[];
    for (final child in folder.children) {
      switch (child) {
        case Bookmark():
          if (child.title.toLowerCase().contains(query) ||
              child.url.toLowerCase().contains(query)) {
            filteredChildren.add(child);
          }
        case BookmarkFolder():
          final filtered = _filterFolder(child, query);
          if (filtered != null) filteredChildren.add(filtered);
      }
    }
    if (filteredChildren.isEmpty) return null;
    return BookmarkFolder(
      title: folder.title,
      children: filteredChildren,
      dirName: folder.dirName,
    );
  }

  /// Navigates the folder tree by a `/`-separated path using [dirName].
  BookmarkFolder? _findFolderByPath(List<BookmarkFolder> folders, String path) {
    final parts = path.split('/');
    List<BookmarkFolder> searchIn = folders;
    BookmarkFolder? current;
    for (final part in parts) {
      current = null;
      for (final f in searchIn) {
        if ((f.dirName ?? f.title) == part) {
          current = f;
          break;
        }
      }
      if (current == null) return null;
      searchIn = current.children.whereType<BookmarkFolder>().toList();
    }
    return current;
  }

  /// Returns the full repo path for a folder (e.g. "bookmarks/toolbar/development").
  String? getFolderPath(BookmarkFolder folder) {
    final c = _credentials;
    if (c == null) return null;
    final found = _findFolderPath(_rootFolders, folder, '');
    return found != null ? '${c.basePath}$found' : null;
  }

  String? _findFolderPath(
      List<BookmarkFolder> folders, BookmarkFolder target, String prefix) {
    for (final f in folders) {
      final path = '$prefix/${f.dirName ?? f.title}';
      if (identical(f, target)) return path;
      final inChild = _findFolderPath(
        f.children.whereType<BookmarkFolder>().toList(),
        target,
        path,
      );
      if (inChild != null) return inChild;
    }
    return null;
  }

  /// Moves a bookmark from source folder to target folder. Persists to GitHub.
  Future<bool> moveBookmarkToFolder(
    Bookmark bookmark,
    BookmarkFolder sourceFolder,
    BookmarkFolder targetFolder,
  ) async {
    final c = _credentials;
    if (c == null || !c.isValid) {
      _error = 'Configure GitHub connection in Settings';
      notifyListeners();
      return false;
    }

    final fromPath = getFolderPath(sourceFolder);
    final toPath = getFolderPath(targetFolder);
    if (fromPath == null || toPath == null || fromPath == toPath) return false;

    _isLoading = true;
    _error = null;
    _lastSuccessMessage = null;
    notifyListeners();

    try {
      final ok =
          await _repository.moveBookmarkToFolder(c, fromPath, toPath, bookmark);
      if (ok) {
        _rootFolders =
            _applyMove(bookmark, sourceFolder, targetFolder, _rootFolders);
        await _cache.saveCache(c.cacheKey, _rootFolders);
        _lastSuccessMessage = 'Bookmark moved';
        notifyListeners();
        return true;
      }
      return false;
    } on GithubApiException catch (e) {
      _error = e.statusCode != null
          ? 'Error ${e.statusCode}: ${e.message}'
          : e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Creates a new subfolder within a parent folder. Persists to GitHub.
  Future<bool> createFolder(
    BookmarkFolder parentFolder,
    String folderTitle,
  ) async {
    final c = _credentials;
    if (c == null || !c.isValid) {
      _error = 'Configure GitHub connection in Settings';
      notifyListeners();
      return false;
    }

    final parentPath = getFolderPath(parentFolder);
    if (parentPath == null) return false;

    _isLoading = true;
    _error = null;
    _lastSuccessMessage = null;
    notifyListeners();

    try {
      final ok = await _repository.createFolder(c, parentPath, folderTitle);
      if (ok) {
        final slug = folderTitle
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
            .replaceAll(RegExp(r'^-+|-+$'), '');
        final newFolder = BookmarkFolder(
          title: folderTitle,
          children: [],
          dirName: slug.isEmpty ? 'untitled' : slug,
        );
        final newChildren = [...parentFolder.children, newFolder];
        _rootFolders =
            _replaceFolderInTree(_rootFolders, parentFolder, newChildren);
        await _cache.saveCache(c.cacheKey, _rootFolders);
        _lastSuccessMessage = 'Folder created';
        notifyListeners();
      }
      return ok;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Edits a bookmark's title and/or URL. Persists to GitHub.
  Future<bool> editBookmark(
    Bookmark bookmark,
    BookmarkFolder sourceFolder, {
    required String newTitle,
    required String newUrl,
  }) async {
    final c = _credentials;
    if (c == null || !c.isValid) {
      _error = 'Configure GitHub connection in Settings';
      notifyListeners();
      return false;
    }

    final folderPath = getFolderPath(sourceFolder);
    if (folderPath == null) return false;

    _isLoading = true;
    _error = null;
    _lastSuccessMessage = null;
    notifyListeners();

    try {
      final ok = await _repository.editBookmarkInFolder(
        c,
        folderPath,
        bookmark,
        newTitle: newTitle,
        newUrl: newUrl,
      );
      if (ok) {
        final updated =
            Bookmark(title: newTitle, url: newUrl, filename: bookmark.filename);
        final newChildren = sourceFolder.children.map((child) {
          if (identical(child, bookmark)) return updated;
          return child;
        }).toList();
        _rootFolders =
            _replaceFolderInTree(_rootFolders, sourceFolder, newChildren);
        await _cache.saveCache(c.cacheKey, _rootFolders);
        _lastSuccessMessage = 'Bookmark updated';
        notifyListeners();
      }
      return ok;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Deletes a bookmark from its folder. Persists to GitHub.
  Future<bool> deleteBookmark(
    Bookmark bookmark,
    BookmarkFolder sourceFolder,
  ) async {
    final c = _credentials;
    if (c == null || !c.isValid) {
      _error = 'Configure GitHub connection in Settings';
      notifyListeners();
      return false;
    }

    final folderPath = getFolderPath(sourceFolder);
    if (folderPath == null) return false;

    _isLoading = true;
    _error = null;
    _lastSuccessMessage = null;
    notifyListeners();

    try {
      final ok =
          await _repository.deleteBookmarkFromFolder(c, folderPath, bookmark);
      if (ok) {
        final newChildren = sourceFolder.children
            .where((c) => !identical(c, bookmark))
            .toList();
        _rootFolders =
            _replaceFolderInTree(_rootFolders, sourceFolder, newChildren);
        await _cache.saveCache(c.cacheKey, _rootFolders);
        _lastSuccessMessage = 'Bookmark deleted';
        notifyListeners();
        return true;
      }
      return false;
    } on GithubApiException catch (e) {
      _error = e.statusCode != null
          ? 'Error ${e.statusCode}: ${e.message}'
          : e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<BookmarkFolder> _replaceFolderInTree(
    List<BookmarkFolder> folders,
    BookmarkFolder target,
    List<BookmarkNode> newChildren,
  ) {
    return folders.map((f) {
      if (identical(f, target)) {
        return BookmarkFolder(
          title: f.title,
          children: newChildren,
          dirName: f.dirName,
        );
      }
      return BookmarkFolder(
        title: f.title,
        children: f.children.map((c) {
          if (c is BookmarkFolder) {
            return _replaceFolderInTree([c], target, newChildren).single;
          }
          return c;
        }).toList(),
        dirName: f.dirName,
      );
    }).toList();
  }

  List<BookmarkFolder> _applyMove(
    Bookmark bookmark,
    BookmarkFolder sourceFolder,
    BookmarkFolder targetFolder,
    List<BookmarkFolder> folders,
  ) {
    return folders.map((f) {
      if (identical(f, sourceFolder)) {
        final newChildren = f.children.where((c) => c != bookmark).toList();
        return BookmarkFolder(
            title: f.title, children: newChildren, dirName: f.dirName);
      }
      if (identical(f, targetFolder)) {
        final targetBookmark = Bookmark(
          title: bookmark.title,
          url: bookmark.url,
          filename: bookmarkFilename(bookmark.title, bookmark.url),
        );
        final newChildren = [...f.children, targetBookmark];
        return BookmarkFolder(
            title: f.title, children: newChildren, dirName: f.dirName);
      }
      return BookmarkFolder(
        title: f.title,
        children: f.children.map((c) {
          if (c is BookmarkFolder) {
            return _applyMove(bookmark, sourceFolder, targetFolder, [c]).single;
          }
          return c;
        }).toList(),
        dirName: f.dirName,
      );
    }).toList();
  }

  /// Reorders children in a folder and persists to GitHub.
  /// [folderPath] is the full repo path (e.g. "bookmarks/toolbar" or "bookmarks/toolbar/development").
  Future<bool> reorderInFolder(
    BookmarkFolder folder,
    String folderPath,
    int oldIndex,
    int newIndex,
  ) async {
    if (oldIndex == newIndex) return true;
    final c = _credentials;
    if (c == null || !c.isValid) {
      _error = 'Configure GitHub connection in Settings';
      notifyListeners();
      return false;
    }

    final children = List<BookmarkNode>.from(folder.children);
    if (oldIndex < 0 ||
        oldIndex >= children.length ||
        newIndex < 0 ||
        newIndex >= children.length) {
      return false;
    }
    final item = children.removeAt(oldIndex);
    children.insert(newIndex, item);

    final orderEntries = children.map<OrderEntry>((node) {
      switch (node) {
        case Bookmark():
          return OrderEntry.file(bookmarkFilename(node.title, node.url));
        case BookmarkFolder():
          final f = node;
          return OrderEntry.folder(f.dirName ?? f.title, f.title);
      }
    }).toList();
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final ok =
          await _repository.updateOrderInFolder(c, folderPath, orderEntries);
      if (ok) {
        _rootFolders = _replaceFolderInTree(_rootFolders, folder, children);
        await _cache.saveCache(c.cacheKey, _rootFolders);
        _lastSuccessMessage = 'Order updated'; // Localized in UI
        notifyListeners();
        return true;
      }
      return false;
    } on GithubApiException catch (e) {
      _error = e.statusCode != null
          ? 'Error ${e.statusCode}: ${e.message}'
          : e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  int _countBookmarks(List<BookmarkFolder> folders) {
    var count = 0;
    for (final folder in folders) {
      for (final child in folder.children) {
        if (child is Bookmark) {
          count++;
        } else if (child is BookmarkFolder) {
          count += _countBookmarks([child]);
        }
      }
    }
    return count;
  }

  /// Access sync state service (for history, undo, etc.).
  SyncStateService get syncStateService => _syncState;
}
