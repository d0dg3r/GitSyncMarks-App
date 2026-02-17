import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bookmark.dart';

class BookmarkService {
  static const String _cacheKey = 'cached_bookmarks';
  static const String _lastSyncKey = 'last_sync_time';
  static const String bookmarksUrl = 
      'https://raw.githubusercontent.com/d0dg3r/GitSyncMarks/main/bookmarks.json';

  Future<List<Bookmark>> fetchBookmarks({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await _getCachedBookmarks();
      if (cached != null) {
        return cached;
      }
    }

    try {
      final response = await http.get(Uri.parse(bookmarksUrl));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final bookmarks = _parseBookmarks(data);
        await _cacheBookmarks(bookmarks);
        await _updateLastSyncTime();
        return bookmarks;
      } else {
        final cached = await _getCachedBookmarks();
        if (cached != null) {
          return cached;
        }
        throw Exception('Failed to load bookmarks: ${response.statusCode}');
      }
    } catch (e) {
      final cached = await _getCachedBookmarks();
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }

  List<Bookmark> _parseBookmarks(dynamic data) {
    final bookmarks = <Bookmark>[];
    
    if (data is Map<String, dynamic>) {
      if (data['roots'] != null) {
        final roots = data['roots'] as Map<String, dynamic>;
        
        if (roots['bookmark_bar'] != null) {
          bookmarks.add(Bookmark.fromJson({
            ...roots['bookmark_bar'],
            'id': 'toolbar',
            'title': 'Bookmarks Toolbar',
          }));
        }
        
        if (roots['other'] != null) {
          bookmarks.add(Bookmark.fromJson({
            ...roots['other'],
            'id': 'other',
            'title': 'Other Bookmarks',
          }));
        }
      } else if (data['children'] != null) {
        for (var child in data['children']) {
          bookmarks.add(Bookmark.fromJson(child));
        }
      } else {
        bookmarks.add(Bookmark.fromJson(data));
      }
    } else if (data is List) {
      for (var item in data) {
        bookmarks.add(Bookmark.fromJson(item));
      }
    }
    
    return bookmarks;
  }

  Future<void> _cacheBookmarks(List<Bookmark> bookmarks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(
      bookmarks.map((b) => b.toJson()).toList(),
    );
    await prefs.setString(_cacheKey, jsonString);
  }

  Future<List<Bookmark>?> _getCachedBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_cacheKey);
      
      if (jsonString == null) return null;
      
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => Bookmark.fromJson(json)).toList();
    } catch (e) {
      return null;
    }
  }

  Future<void> _updateLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastSyncKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_lastSyncKey);
  }
}
