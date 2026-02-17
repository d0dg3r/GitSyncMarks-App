class Bookmark {
  final String id;
  final String title;
  final String? url;
  final List<Bookmark> children;
  final BookmarkType type;

  Bookmark({
    required this.id,
    required this.title,
    this.url,
    this.children = const [],
    required this.type,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    final type = json['type'] == 'folder' 
        ? BookmarkType.folder 
        : BookmarkType.link;
    
    final children = <Bookmark>[];
    if (json['children'] != null) {
      for (var child in json['children']) {
        children.add(Bookmark.fromJson(child));
      }
    }

    return Bookmark(
      id: json['id'] ?? json['guid'] ?? '',
      title: json['title'] ?? json['name'] ?? '',
      url: json['url'] ?? json['uri'],
      children: children,
      type: type,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'type': type == BookmarkType.folder ? 'folder' : 'link',
      'children': children.map((c) => c.toJson()).toList(),
    };
  }

  bool get isFolder => type == BookmarkType.folder;
}

enum BookmarkType {
  folder,
  link,
}
