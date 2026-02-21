/// Base type for nodes in the bookmark tree.
sealed class BookmarkNode {
  const BookmarkNode();
}

/// A single bookmark (leaf node).
class Bookmark extends BookmarkNode {
  const Bookmark({required this.title, required this.url, this.filename});

  final String title;
  final String url;
  /// Actual filename in the repo (e.g. "github_a1b2.json"). Used for move/delete.
  final String? filename;

  @override
  String toString() => 'Bookmark($title, $url)';
}

/// A folder containing bookmark nodes (bookmarks and/or subfolders).
class BookmarkFolder extends BookmarkNode {
  const BookmarkFolder({
    required this.title,
    required this.children,
    this.dirName,
  });

  /// Display name (from _order.json "title" or folder name).
  final String title;

  /// Child nodes in display order.
  final List<BookmarkNode> children;

  /// Repo directory name for _order.json (subfolders). Null = use title.
  final String? dirName;

  @override
  String toString() => 'BookmarkFolder($title, ${children.length} children)';
}
