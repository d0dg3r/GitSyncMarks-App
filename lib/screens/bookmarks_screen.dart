import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/bookmark.dart';
import '../services/bookmark_service.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final BookmarkService _bookmarkService = BookmarkService();
  List<Bookmark> _bookmarks = [];
  bool _isLoading = true;
  String? _error;
  DateTime? _lastSync;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final bookmarks = await _bookmarkService.fetchBookmarks(
        forceRefresh: forceRefresh,
      );
      final lastSync = await _bookmarkService.getLastSyncTime();
      
      setState(() {
        _bookmarks = bookmarks;
        _lastSync = lastSync;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = _getUserFriendlyErrorMessage(e);
        _isLoading = false;
      });
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GitSyncMarks'),
        actions: [
          if (_lastSync != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Last sync: ${_formatDateTime(_lastSync!)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : () => _loadBookmarks(forceRefresh: true),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadBookmarks(forceRefresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_bookmarks.isEmpty) {
      return const Center(
        child: Text('No bookmarks found'),
      );
    }

    return ListView.builder(
      itemCount: _bookmarks.length,
      itemBuilder: (context, index) {
        return BookmarkTile(
          bookmark: _bookmarks[index],
          onTap: _openUrl,
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  String _getUserFriendlyErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('socketexception') || 
        errorString.contains('network') ||
        errorString.contains('connection')) {
      return 'Unable to connect to the network. Please check your internet connection.';
    } else if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else if (errorString.contains('404')) {
      return 'Bookmarks file not found in the repository.';
    } else if (errorString.contains('format')) {
      return 'Invalid bookmark format. Please check the bookmarks file.';
    } else {
      return 'Failed to load bookmarks. Please try again later.';
    }
  }
}

class BookmarkTile extends StatelessWidget {
  final Bookmark bookmark;
  final Function(String) onTap;

  const BookmarkTile({
    super.key,
    required this.bookmark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (bookmark.isFolder) {
      return ExpansionTile(
        leading: const Icon(Icons.folder),
        title: Text(bookmark.title),
        children: bookmark.children.map((child) {
          return BookmarkTile(
            bookmark: child,
            onTap: onTap,
          );
        }).toList(),
      );
    } else {
      return ListTile(
        leading: const Icon(Icons.link),
        title: Text(bookmark.title),
        subtitle: bookmark.url != null ? Text(
          bookmark.url!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ) : null,
        onTap: () {
          if (bookmark.url != null) {
            onTap(bookmark.url!);
          }
        },
      );
    }
  }
}
