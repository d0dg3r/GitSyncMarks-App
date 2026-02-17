import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import '../config/github_credentials.dart';
import '../models/bookmark_node.dart';
import '../repositories/bookmark_repository.dart';
import '../services/bookmark_cache.dart';
import '../services/github_api.dart';
import '../services/storage_service.dart';

/// App state: credentials, bookmarks, sync status.
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

  GithubCredentials? _credentials;
  List<BookmarkFolder> _rootFolders = [];
  List<String> _discoveredRootFolderNames = [];
  List<String> _selectedRootFolders = [];
  bool _isLoading = false;
  String? _error;
  String? _lastSuccessMessage;

  GithubCredentials? get credentials => _credentials;

  List<BookmarkFolder> get rootFolders => _rootFolders;

  List<BookmarkFolder> get displayedRootFolders {
    if (_selectedRootFolders.isEmpty) return _rootFolders;
    final names = _selectedRootFolders.toSet();
    return _rootFolders
        .where((f) => names.contains(f.title))
        .toList();
  }

  List<String> get availableRootFolderNames =>
      _rootFolders.isNotEmpty
          ? _rootFolders.map((f) => f.title).toList()
          : _discoveredRootFolderNames;

  List<String> get selectedRootFolders => List.unmodifiable(_selectedRootFolders);

  bool get isLoading => _isLoading;

  String? get error => _error;

  String? get lastSuccessMessage => _lastSuccessMessage;

  bool get hasCredentials => _credentials?.isValid ?? false;

  bool get hasBookmarks => _rootFolders.isNotEmpty;

  /// Loads saved credentials and selected root folders from storage.
  /// Also loads cached bookmarks if credentials are valid.
  Future<void> loadCredentials() async {
    _credentials = await _storage.loadCredentials();
    _selectedRootFolders = await _storage.loadSelectedRootFolders();
    _error = null;
    if (_credentials != null && _credentials!.isValid) {
      await loadFromCache();
    } else {
      notifyListeners();
    }
  }

  /// Loads bookmarks from local cache for current credentials.
  /// Does nothing if credentials are missing or invalid.
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

  /// Updates selected root folders (empty = show all) and optionally persists.
  Future<void> setSelectedRootFolders(List<String> names, {bool save = false}) async {
    _selectedRootFolders = names.toList();
    if (save) {
      await _storage.saveSelectedRootFolders(_selectedRootFolders);
    }
    notifyListeners();
  }

  /// Updates credentials (from Settings form) and optionally persists.
  Future<void> updateCredentials(GithubCredentials creds, {bool save = false}) async {
    _credentials = creds;
    if (save) {
      await _storage.saveCredentials(creds);
    }
    _error = null;
    notifyListeners();
  }

  /// Saves current credentials to storage.
  Future<void> saveCredentials() async {
    if (_credentials != null) {
      await _storage.saveCredentials(_credentials!);
      _lastSuccessMessage = 'Settings saved';
      notifyListeners();
    }
  }

  /// Tests connection without fetching full bookmarks.
  /// On success, stores discovered root folder names for the folder selection UI.
  Future<bool> testConnection(GithubCredentials creds) async {
    _isLoading = true;
    _error = null;
    _lastSuccessMessage = null;
    notifyListeners();

    try {
      _discoveredRootFolderNames =
          await _repository.testConnection(creds);
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

  /// Fetches bookmarks from GitHub and updates state.
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
      final bookmarkCount = _countBookmarks(_rootFolders);
      _lastSuccessMessage =
          'Synced ${_rootFolders.length} folder(s), $bookmarkCount bookmark(s)';
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

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Seeds the provider with test data for screenshot generation.
  /// Use in test/screenshot_test.dart only.
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
    _selectedRootFolders =
        folders.map((f) => f.title).toList();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  void clearSuccessMessage() {
    _lastSuccessMessage = null;
    notifyListeners();
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
