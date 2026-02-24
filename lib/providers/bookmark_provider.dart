import 'dart:async';

import 'package:flutter/foundation.dart';

import '../config/github_credentials.dart';
import '../models/bookmark_node.dart';
import '../models/profile.dart';
import '../repositories/bookmark_repository.dart';
import '../services/bookmark_cache.dart';
import '../services/github_api.dart';
import '../services/settings_sync_service.dart';
import '../services/storage_service.dart';
import '../utils/bookmark_filename.dart';

/// App state: profiles, credentials, bookmarks, sync status.
class BookmarkProvider extends ChangeNotifier {
  BookmarkProvider({
    StorageService? storage,
    BookmarkRepository? repository,
    BookmarkCacheService? cacheService,
  })  : _storage = storage ?? StorageService(),
        _repository = repository ?? BookmarkRepository(),
        _cache = cacheService ?? BookmarkCacheService();

  final StorageService _storage;
  final BookmarkRepository _repository;
  final BookmarkCacheService _cache;
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
  Timer? _autoSyncTimer;
  DateTime? _nextAutoSyncAt;
  String _searchQuery = '';

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
    if (_selectedRootFolders.isEmpty) return effective;
    final names = _selectedRootFolders.toSet();
    final filtered = effective.where((f) => names.contains(f.title)).toList();
    return filtered.isEmpty ? effective : filtered;
  }

  List<String> get availableRootFolderNames =>
      _effectiveRootFolders.isNotEmpty
          ? _effectiveRootFolders.map((f) => f.title).toList()
          : _discoveredRootFolderNames;

  /// Full folder tree (ignoring viewRootFolder) for the settings picker.
  List<BookmarkFolder> get fullRootFolders => _rootFolders;

  List<String> get selectedRootFolders => List.unmodifiable(_selectedRootFolders);

  bool get isLoading => _isLoading;

  String? get error => _error;

  String? get lastSuccessMessage => _lastSuccessMessage;

  bool get hasCredentials => _credentials?.isValid ?? false;

  bool get hasBookmarks => _rootFolders.isNotEmpty;

  bool get canAddProfile => _profiles.length < maxProfiles;

  DateTime? get lastSyncTime => _lastSyncTime;

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
  }) async {
    final active = activeProfile;
    if (active == null) return;
    _profiles = _profiles.map((p) {
      if (p.id == _activeProfileId) {
        return p.copyWith(
          autoSyncEnabled: autoSyncEnabled ?? p.autoSyncEnabled,
          syncProfile: syncProfile ?? p.syncProfile,
          customIntervalMinutes: customIntervalMinutes ?? p.customIntervalMinutes,
          syncOnStart: syncOnStart ?? p.syncOnStart,
          allowMoveReorder: allowMoveReorder ?? p.allowMoveReorder,
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

  Future<void> setSelectedRootFolders(List<String> names, {bool save = false}) async {
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

  Future<void> updateCredentials(GithubCredentials creds, {bool save = false}) async {
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
      final ok = await _repository.addBookmarkToFolder(c, folderPath, title, url);
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
      _rootFolders = await _repository.fetchBookmarks(c);
      await _cache.saveCache(c.cacheKey, _rootFolders);
      _lastSyncTime = DateTime.now();
      final bc = _countBookmarks(_rootFolders);
      _lastSuccessMessage =
          'Synced ${_rootFolders.length} folder(s), $bc bookmark(s)';

      final syncSettingsToGit = await _storage.loadSyncSettingsToGit();
      if (syncSettingsToGit) {
        final password = await _storage.loadSettingsSyncPassword();
        if (password != null && password.isNotEmpty) {
          final mode = await _storage.loadSettingsSyncMode();
          final deviceId = await _storage.getOrCreateDeviceId();
          if (mode == 'global') {
            try {
              final result = await _settingsSync.pull(c, password);
              if (result.syncSettingsToGit != null) {
                await _storage.saveSyncSettingsToGit(result.syncSettingsToGit!);
              }
              if (result.settingsSyncMode != null) {
                await _storage.saveSettingsSyncMode(result.settingsSyncMode!);
              }
              await replaceProfiles(result.profiles, activeId: result.activeProfileId, triggerSync: false);
            } catch (_) {
              // settings.enc may not exist yet; ignore
            }
          }
          if (_profiles.isNotEmpty) {
            try {
              final activeId = _activeProfileId ?? _profiles.first.id;
              await _settingsSync.push(
                c,
                _profiles,
                activeId,
                password,
                mode: mode,
                deviceId: deviceId,
                syncSettingsToGit: syncSettingsToGit,
                settingsSyncMode: mode,
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
  // Misc
  // ---------------------------------------------------------------------------

  /// Resets all data (profiles, credentials, cache) to factory state.
  Future<void> resetAll() async {
    _stopAutoSync();
    await _storage.resetAll();
    await _cache.clearCache();
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

  String? _findFolderPath(List<BookmarkFolder> folders, BookmarkFolder target, String prefix) {
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
      final ok = await _repository.moveBookmarkToFolder(c, fromPath, toPath, bookmark);
      if (ok) {
        _rootFolders = _applyMove(bookmark, sourceFolder, targetFolder, _rootFolders);
        await _cache.saveCache(c.cacheKey, _rootFolders);
        _lastSuccessMessage = 'Bookmark moved';
        notifyListeners();
        return true;
      }
      return false;
    } on GithubApiException catch (e) {
      _error = e.statusCode != null ? 'Error ${e.statusCode}: ${e.message}' : e.message;
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
      final ok = await _repository.deleteBookmarkFromFolder(c, folderPath, bookmark);
      if (ok) {
        final newChildren = sourceFolder.children
            .where((c) => !identical(c, bookmark))
            .toList();
        _rootFolders = _replaceFolderInTree(_rootFolders, sourceFolder, newChildren);
        await _cache.saveCache(c.cacheKey, _rootFolders);
        _lastSuccessMessage = 'Bookmark deleted';
        notifyListeners();
        return true;
      }
      return false;
    } on GithubApiException catch (e) {
      _error = e.statusCode != null ? 'Error ${e.statusCode}: ${e.message}' : e.message;
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
        return BookmarkFolder(title: f.title, children: newChildren, dirName: f.dirName);
      }
      if (identical(f, targetFolder)) {
        final targetBookmark = Bookmark(
          title: bookmark.title,
          url: bookmark.url,
          filename: bookmarkFilename(bookmark.title, bookmark.url),
        );
        final newChildren = [...f.children, targetBookmark];
        return BookmarkFolder(title: f.title, children: newChildren, dirName: f.dirName);
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
    if (oldIndex < 0 || oldIndex >= children.length || newIndex < 0 || newIndex >= children.length) {
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
      final ok = await _repository.updateOrderInFolder(c, folderPath, orderEntries);
      if (ok) {
        _rootFolders = _replaceFolderInTree(_rootFolders, folder, children);
        await _cache.saveCache(c.cacheKey, _rootFolders);
        _lastSuccessMessage = 'Order updated'; // Localized in UI
        notifyListeners();
        return true;
      }
      return false;
    } on GithubApiException catch (e) {
      _error = e.statusCode != null ? 'Error ${e.statusCode}: ${e.message}' : e.message;
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
}
